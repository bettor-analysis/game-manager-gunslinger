# Game Manager vs Gunslinger


library(tidyverse)
library(janitor)
library(nflfastR)
library(ggrepel)
library(ggimage)

seasons <- 2024

pbp <- load_pbp(seasons)

pbp %>% filter(qb_dropback == 1, !is.na(epa)) -> passes

passes <- passes %>% mutate(year = substr(game_id,1,4))


Stats <- passes %>% filter(home_wp > 0.1, home_wp < 0.9, qb_dropback==1) %>% 
  mutate(QB = ifelse(is.na(passer_player_name), rusher_player_name, passer_player_name)) %>% 
  group_by(QB, year) %>% 
  summarize(numDropbacks = n(),
            passAttempts = sum(pass_attempt),
            
            #Game Manager Calculations:
            completions = sum(complete_pass),
            completionPercent = completions / passAttempts,
            ints = sum(interception),
            sacks = sum(sack)/numDropbacks,
            successRate = mean(success),
            
            #Gunslinger Calculations:
            meanAirYards = mean(air_yards, na.rm=TRUE),
            tds = sum(touchdown),
            shortOfSticksOnThird = sum(down==3 & air_yards < ydstogo & third_down_failed, na.rm=TRUE),
            thirdDownDropbacks = sum(down==3, na.rm=TRUE ),
            shortOfSticksOnThirdRate = shortOfSticksOnThird / thirdDownDropbacks,  
            passYards = sum(yards_gained[pass_attempt==1], na.rm=TRUE),
            rushYards = sum(yards_gained[pass_attempt==0], na.rm=TRUE),
            team = last(posteam),
            throwAways = sum(is.na(receiver_player_name) & pass_attempt==1),
            throwAwayRate = throwAways/numDropbacks,
            
            #EPA
            meanEPA = mean(epa),
            sdEPA = sd(epa)
  ) %>% 
  filter(passAttempts > 10) %>%
  arrange(desc(meanEPA)) %>% mutate(ID = paste(QB, "_", year))


Gunslinger <- Stats %>% select(QB, year, tds, passYards, meanAirYards, rushYards, shortOfSticksOnThirdRate, team)
cols <- c('tds', 'passYards', 'rushYards', 'shortOfSticksOnThirdRate', 'meanAirYards')
tdWeight <- 0.75
passWeight <- 0.5
rushWeight <- 0.25
shortWeight <- 0.75
airWeight <- 1
Gunslinger[cols] <- scale(Gunslinger[cols])
Gunslinger <- Gunslinger %>% mutate(GunslingScore = tdWeight* tds + passWeight* passYards + rushWeight* rushYards - shortWeight * shortOfSticksOnThirdRate + airWeight* meanAirYards) %>%  arrange(-GunslingScore)
Gunslinger$GunslingScore <- scale(Gunslinger$GunslingScore)


Manager <- Stats %>% select(QB, year, ints, successRate, sacks, completionPercent, team, meanEPA, sdEPA)
cols <- c('ints', 'successRate', 'sacks', 'completionPercent')
Manager[cols] <- scale(Manager[cols])
intWeight <- 1
successWeight <- 0.70
sacksWeight <- 0.50
completeWeight <- 75
Manager <- Manager %>% mutate(ManageScore = -1*ints*intWeight + successRate*successWeight - sacks*sacksWeight + completionPercent*completeWeight) %>%  arrange(-ManageScore) 
Manager$ManageScore <- scale(Manager$ManageScore)


Combined <- Gunslinger %>% left_join(Manager) %>%  left_join(teams_colors_logos, by = c('team' = 'team_abbr')) %>% arrange(-GunslingScore)


# Plot with Adjusted Labels
Combined %>% 
  #filter(year == 2024) %>%  # Uncomment to filter by year if you bring in multiple years of pbp
  ggplot(aes(x = ManageScore, y = GunslingScore, label = QB)) +
  geom_image(aes(image = team_logo_espn), size = 0.04) +  # Adjusted size for clarity
  geom_text_repel(
    aes(label = QB), 
    size = 3,  # Adjust text size as needed
    nudge_x = 0.15, 
    nudge_y = 0.15,
    segment.size = 0.2,     # Adds subtle line segments for clarity
    segment.color = "grey50",   # Grey lines to connect labels to points
    box.padding = 0.4,    # Increased padding to prevent overlap
    point.padding = 0.6,  # Increased padding around points
    max.overlaps = 15,    # Adjust based on the number of labels
    force = 1             # Increased force to push labels further away
  ) + 
  geom_hline(yintercept = 0, color = "red", linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed", alpha = 0.5) + 
  labs(x = "Game Managing Performance (ManageScore)", 
       y = "Gunslinging Performance (GunslingScore)",
       title = "2024 NFL QBs: Game Managers vs. Gunslingers",
       caption = "Data: nflfastR") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, face = "italic"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )



