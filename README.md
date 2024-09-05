# Modelling the Game Outcome with Madden Player Ratings

This was my final project for the seminar "Statistics of the NFL", conducted by [Prof. Donna Ankerst](https://www.professoren.tum.de/ankerst-donna) in the winter semester 2022/23. As a passionate Eagles fan, this course quickly became one of my favorites during my master’s degree. It allowed me to explore my favorite sport through the perspective of machine learning.

## Motivation

The idea of using video games to predict the outcomes of sports matches was not new to me. As a child, my friend and I would predict soccer game results by playing the matchups in FIFA before watching them live. Oddly, our predictions always seemed to favor my friend’s favorite teams.

Putting childhood anecdotes aside, sports simulation games might actually have predictive power. Since 2004, EA Sports has been attempting to predict the Super Bowl outcome using its latest Madden NFL game, achieving a [success rate of 12 correct predictions out of the last 21](https://en.wikipedia.org/wiki/Madden_NFL). In particular, in-game player ratings could serve as a valuable addition to other available NFL data. While play-by-play data from the NFL is widely accessible through projects like nflverse, it remains challenging to attribute the outcome of a play to individual players. This is where Madden’s player ratings, which include attributes such as speed and strength, could provide a new dimension for analysis. 

In fact, [Fernandes et al.](https://content.iospress.com/download/journal-of-sports-analytics/jsa190348?id=journal-of-sports-analytics%2Fjsa190348) have already successfully utilized player ratings to predict offensive play types. So, why not use Madden player ratings to answer to the most pressing question in sports: which team will?

## Data

For my project, I analyzed data from the 2004 to 2020 NFL seasons, combining information from three distinct sources to build my model:

1. **Game Statistics**: I utilized the [nflreadr](https://nflreadr.nflverse.com) package to extract detailed game statistics, which included a running average of points scored and allowed for each team, as well as indicators for whether the team was playing at home and if the game was a division matchup.

2. **Weather Data**: To account for the potential impact of weather conditions on game scores and outcomes, I incorporated data from [Tom Bliss's NFL weather dataset](https://www.datawithbliss.com/weather-data), which was obtained via the Meteostat API.

3. **Player Ratings**: I obtained Madden player ratings for each season from the [Madden Ratings Weebly](https://maddenratings.weebly.com) website. I scraped this data for the individual seasons and compiled it into a single, comprehensive dataset.

I used the seasons from 2004 until 2018 for training and validation and the remaining two seasons 2019 and 2020 as my test set.

## Modelling Assumptions

While it is common practice to model game outcomes as a binary variable (win or loss), I believe that incorporating the actual scores provides a richer signal. For instance, a game ending 17-16 could easily have gone either way, while a 35-10 result clearly indicates a dominant performance by one team. However, this approach does add complexity, as it requires modeling two separate scores instead of a single binary variable.

To address this added complexity, I model the scores of each game separately by focusing on the matchups between the offense and defense. Specifically, I predict the score that the offense will achieve against a given defense. An added benefit of this approach is that it effectively doubles the number of training examples, as each game consists of two such matchups. However, this method also introduces some bias, as it assumes the performance of a team’s offense and defense are independent of each other. In reality, factors like momentum—where a successful offensive drive might positively influence defensive performance—can create interdependencies between the two.

## Challenges
### 1. Selecting relevant Player Ratings for each Games

On average, a Madden team consists of 66 players. However, not all players contribute equally to the team’s performance, so their ratings shouldn’t be weighted the same way. To accurately assess a team’s strength, one should focus on the key players — specifically, those with the best ratings for each position.

Football is a sport heavily impacted by injuries, where even a star player like the quarterback can be sidelined, drastically affecting team performance. It’s important to keep track of this, and fortunately, nflreadr provides weekly depth charts for each team. These charts rank players by position and prioritize them based on their likelihood of playing time.

Analyzing the data reveals that players listed as first-team depth (starters) participate in over 90% of the snaps on average. In contrast, second-team players see around 25% of the snaps, with even less playing time for those on the third team. Therefore, to simplify the analysis and focus on the most impactful players, I only consider those listed on the first depth team.

<img src="assets/depth_team_snaps.png" width="900px">

### 2. Handling Missing Data

Focusing on the player ratings of the first depth team, I tried to compute the average rating for each position. However, I encountered some missing values for certain positions. One issue is that Madden does not have a license for every player, leading to some gaps in the data. Additionally, when players are traded mid-season, it can be challenging to match them with the Madden player base.

To address these issues, I grouped positions into broader categories to minimize the impact of missing data. For example, I combined offensive tackle, offensive guard, and center into a single category called “offensive line.” Then, I calculated the average rating of players in the first depth team for each of these broader position groups.

![image](assets/grouping_positions.jpg)

### 3. Handling the Distribution Shift in Player Ratings

While player ratings in each version of Madden provide a good measure of how players compare to one another, I needed to ensure that these ratings were comparable across different versions of the game to train a model effectively. Upon examining the data, I noticed a shift in player ratings over time; overall, it appears that player ratings have generally declined over the years. To address this, rather than using the raw player ratings, I calculated the average rating for each position group by season and categorized them into four groups:

1. Ratings below the 1st quartile
2. Ratings between the 1st and 2nd quartiles
3. Ratings between the 2nd and 3rd quartiles
4. Ratings above the 3rd quartile

 <img src="assets/distribution_shift_in_player_ratings.png" width="400px">

## Data Exploration

Let’s explore some interesting interactions and matchups within the game, such as the matchup between wide receivers and defensive backs, who are direct counterparts on the field. For example, consider a scenario where a team with highly-rated receivers (Group 4) faces off against a team with poorly-rated defensive backs (Group 1). The heatmap below illustrates the average score for various matchups of this kind. As expected, the data shows that the better the receivers, the higher the average score, while stronger defensive backs result in a lower score. A similar pattern was observed in matchups between the offensive line and defensive line.

![image](assets/offense_vs_defense.png)

Upon examining these heatmaps, I noticed that the diagonals consistently displayed similar average scores. Therefore, I decided to consolidate these features into two new features:
- `pass_matchup` = Rating Receiver - Rating Defensive Backs
- `line_matchup` = Rating Offense Line - Rating Defensive Line

## Multivariate Regression Model

Finally, it was time to train a multivariate regression model to predict the score of an offense against a defense, using the features we created. The first thing I learned is that predicting the exact scores of games is extremely challenging, and traditional performance metrics like R-squared tend to be low. As I later discovered, this is quite common when modeling the scores of football matches.

However, many of our predictors are statistically significant, and the coefficients reveal some interesting insights. First, it appears that poor weather conditions generally lead to lower scores. Additionally, the home advantage is evident: teams tend to score more goals when playing at home, even more so against division rivals.

Among the features based on Madden ratings, I found several intriguing results. The quarterback rating has the largest impact on the score, which aligns with expectations. Interestingly, the running back rating is negatively correlated with the score. A possible explanation for this could be that teams with strong running backs opt for more running plays, which tend to take more time off the clock. Another surprising finding is that the kicker’s rating has almost no effect on the score.

<img src="assets/coeffs.png" width="400px">

## Evaluation

To better understand the model’s performance, I evaluated its predictions for Super Bowl LIV between the San Francisco 49ers and the Kansas City Chiefs. The model’s prediction — a 30-23 win for the Chiefs — was remarkably close to the actual outcome of 31-20. This example (admittedly cherry-picked) illustrates that the model heavily relies on the running averages of points scored and allowed, which seem to have a more significant influence than the Madden ratings.

![image](assets/model_in_action.png)

To rigorously assess the model’s overall performance, I tested it across the entire training set, which includes the 2019 and 2020 NFL seasons. The model predicted the scores for each matchup and selected the team with the higher predicted score as the winner. It correctly predicted the outcomes of 65.4% of the 416 games.

An interesting observation emerged: the model’s accuracy increased with the predicted score spread. For the 52 games where the model predicted a spread of 8 points or more, it was correct 90% of the time. This suggests that when the model is more confident (i.e., predicts a larger margin of victory), its accuracy improves substantially.

![image](assets/evaluation.png)


## Code
You can find the code in the R markdown notebook `nfl_game_prediction.Rmd`.



# Madden Ratings Scraper

This script `madden_ratings_scraper.py` downloads Madden ratings data for a given range of years from `https://maddenratings.weebly.com/`. It stores the data as CSV files in a directory named `madden_data`.

## Installation

1. Clone the repository and navigate to its directory.

2. Create a Python virtual environment:

    ```bash
    python3 -m venv venv
    ```

3. Activate the virtual environment:

    On Unix or MacOS, run:
    
    ```bash
    source venv/bin/activate
    ```
    
    On Windows, run:
    
    ```cmd
    venv\Scripts\activate.bat
    ```

4. Install the required packages:

    ```bash
    pip install -r requirements.txt
    ```

## Usage

To run the script, use the following command, providing the years you want to download data for:

```bash
python madden_ratings_scraper.py --from 05 --to 20
```

Without any arguments, the script will default to downloading data for all years from 02 to the current year + 1:

```bash
python madden_ratings_scraper.py
```

To consolidate your downloaded data into a single, unified .csv file, you can utilize the `combine_madden_ratings.py` script. Execute this script by opening your terminal and entering the following command:

```bash
python combine_madden_ratings.py
```

Upon the successful execution of the script, the resultant file will be stored in the `processed_data` directory. 

## License

This project is open-source and available to everyone under the [MIT License](https://opensource.org/licenses/MIT).

## Contribution

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgments

This project uses data from the [Madden Ratings](https://maddenratings.weebly.com/) website.

## Disclaimer

This script is for educational purposes only. Please respect the terms of use and privacy policies of any websites you scrape.
