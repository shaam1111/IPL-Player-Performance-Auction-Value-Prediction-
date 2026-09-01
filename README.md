# IPL Player Performance & Auction Value Prediction

## Project Overview

This project analyzes IPL player performance statistics and uses Machine Learning to estimate player auction value.

The project combines SQL, Python, and Machine Learning.

The main idea is:

**Player Performance Statistics → Machine Learning Model → Predicted Auction Value**

The model uses historical player performance data such as runs, strike rate, wickets, matches played, sixes, bowling economy, and an overall performance score.

## Objectives

- Store and analyze IPL data using SQL Server.
- Calculate player-level batting and bowling statistics.
- Create a performance score for selected players.
- Use genuine IPL auction/RTM prices as the target variable.
- Train regression models to estimate auction value.
- Compare different Machine Learning models.
- Identify the most influential performance features.

## Technologies Used

- SQL Server
- Python 3
- Pandas
- NumPy
- Matplotlib
- Scikit-learn
- XGBoost
- Google Colab

## Dataset

The project uses IPL match and ball-by-ball data covering IPL seasons from 2008 to 2024.

Main source:

IPL Complete Dataset 2008–2024

Files used:

- `matches.csv`
- `deliveries.csv`

## SQL Database

Database name:

`IPLAnalyticsDB`

Main tables:

- `TEAMS`
- `VENUES`
- `MATCHES`
- `PLAYERS`
- `BATTING_STATS`
- `BOWLING_STATS`
- `RAW_MATCHES`
- `RAW_DELIVERIES`
- `PLAYER_PERFORMANCE_FINAL`
- `PLAYER_AUCTION_DATA`
- `PLAYER_AUCTION_VERIFIED`

## Machine Learning Dataset

The final Machine Learning dataset contains **39 players**.

Virat Kohli was excluded from the ML target dataset because the available ₹0.12 crore value was from the U19 draft rather than a genuine IPL auction/RTM purchase.

### Features Used

- `matches_played`
- `total_runs`
- `balls_faced`
- `total_fours`
- `total_sixes`
- `strike_rate`
- `centuries`
- `half_centuries`
- `ducks`
- `total_wickets`
- `bowling_economy`
- `performance_score`

### Target Variable

`auction_value`

The target represents the genuine auction/RTM price used for the selected players and is measured in crores.

## Machine Learning Process

The Machine Learning workflow was:

1. Load the final SQL dataset into Python.
2. Validate the dataset.
3. Separate features and target.
4. Split the data into training and testing sets using an 80/20 split.
5. Scale the numerical features using StandardScaler.
6. Train three regression models.
7. Compare their performance using MAE, RMSE, and R².
8. Tune the Random Forest model.
9. Select the best-performing model.
10. Generate auction value predictions.
11. Analyze feature importance.

## Models Tested

### 1. Linear Regression

Used as a simple baseline regression model.

### 2. Random Forest

Used to capture more complex relationships between player performance features and auction value.

### 3. XGBoost

Used as another tree-based regression model for comparison.

### 4. Tuned Random Forest

The Random Forest model was tuned using GridSearchCV.

Best parameters:

- `n_estimators = 200`
- `max_depth = 2`
- `min_samples_leaf = 3`
- `random_state = 42`

## Model Results

| Model | MAE | RMSE | R² |
|---|---:|---:|---:|
| Linear Regression | 2.900 | 4.327 | -0.217 |
| Random Forest | 2.849 | 4.167 | -0.129 |
| XGBoost | 2.997 | 4.593 | -0.371 |
| **Tuned Random Forest** | **2.659** | **3.907** | **0.008** |

### Best Model

**Tuned Random Forest**

It achieved the lowest MAE and RMSE and the highest R² among the tested models.

However, the R² value is close to zero, so the model should be considered an academic estimation model rather than a highly accurate real-world auction prediction system.

## Top 5 Influential Features

According to the final Tuned Random Forest model:

1. `strike_rate`
2. `matches_played`
3. `total_sixes`
4. `bowling_economy`
5. `performance_score`

`strike_rate` had the highest feature importance in the final model.

Feature importance shows how strongly the model used each feature when making predictions. It does not prove that a feature directly causes a higher auction price.

## Sample Predictions

The final model was also used to estimate auction values for selected IPL players.

Example predictions:

| Player | Actual Auction Value (Cr) | Predicted Auction Value (Cr) |
|---|---:|---:|
| AJ Finch | 1.50 | 3.166 |
| AM Rahane | 0.50 | 3.356 |
| AT Rayudu | 6.75 | 5.733 |
| BB McCullum | 3.60 | 5.212 |
| CA Pujara | 1.90 | 3.835 |

## Key Finding

The results suggest that scoring ability, experience, power hitting, bowling efficiency, and overall performance were important factors used by the final Random Forest model when estimating auction value.

However, IPL auction prices depend on many factors beyond player statistics, including team requirements, market conditions, player availability, and other real-world considerations.

## Limitations

- The final ML dataset contains only 39 players.
- The test set contains only 8 players.
- Auction values have a wide range, making extreme values difficult to predict.
- The model does not include factors such as team requirements, age, recent form, availability, or auction competition.
- The current model should be viewed as an academic estimation system rather than a system that can guarantee actual IPL auction prices.

## Project Structure

```text
ipl-player-auction-prediction/
│
├── README.md
├── requirements.txt
│
├── data/
│   ├── matches.csv
│   └── deliveries.csv
│
├── sql/
│   ├── schema.sql
│   ├── data_insert.sql
│   └── queries.sql
│
├── notebooks/
│   └── ipl_project.ipynb
│
├── docs/
│   ├── er_diagram.png
│   └── team_owner_report.pdf
│
└── outputs/
    └── charts/
