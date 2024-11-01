NFL QB Styles Analysis: Game Managers vs. Gunslingers

This repository contains code to analyze NFL quarterbacks’ playing styles based on their performance metrics, categorizing QBs as either Gunslingers (aggressive, high-risk players) or Game Managers (consistent, efficiency-focused players). Using play-by-play data, this analysis provides a unique way to quantify and visualize how QBs balance risk and control.

Description

The analysis categorizes QBs by calculating two custom scores:

1.	Gunslinger Score: Reflects QBs inclined towards high-reward, aggressive play. Metrics include:
	•	Touchdowns (TDs) and Passing Yards: Major scoring and yardage indicators.
	•	Air Yards: High air yards suggest riskier throws and big-play potential.
	•	Rushing Yards: Adds value for QBs who can contribute with their legs.
	•	Short-of-Sticks Rate on 3rd Down: Penalized for conservative 3rd down plays short of the first down marker.
2.	Game Manager Score: Emphasizes consistency, efficiency, and ball security. Metrics include:
	•	Interceptions: Heavily penalized to highlight decision-making that protects the ball.
	•	Success Rate: Measures play consistency, capturing reliable execution.
	•	Sack Rate: Penalized to emphasize the importance of pocket management.
	•	Completion Percentage: Highly rewarded for a focus on efficient, safe passing.

These scores are calculated and visualized on a scatter plot, providing a clear view of where each QB falls on the spectrum from Gunslinger to Game Manager. High Gunslinger scores indicate aggressive play, while high Game Manager scores point to a safe, controlled style.

Visualization

The code includes a scatter plot where:

•	Y-axis (Gunslinger Score): Higher values indicate a more aggressive, big-play approach.
•	X-axis (Game Manager Score): Higher values suggest a focus on consistency and efficiency.

The plot’s red dashed lines at zero divide QBs into four quadrants, showing whether they lean more towards Gunslinger, Game Manager, or exhibit a balanced style.

