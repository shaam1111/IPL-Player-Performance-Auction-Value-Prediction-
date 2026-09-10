# IPL Player Performance & Auction Value Prediction

## Project Overview

This project analyzes IPL player performance statistics and uses Machine Learning to estimate player auction value.

**Player Performance Statistics -> Machine Learning Model -> Predicted Auction Value**

The project combines SQL Server for data preparation with Python and Machine Learning for regression.

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

## Machine Learning Dataset

The final Machine Learning dataset contains **39 players** with valid auction/RTM target values.

Virat Kohli was excluded from the ML target because the available ₹0.12 crore value was an U19 draft value rather than a genuine auction/RTM purchase.

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

`auction_value` (Crores)

## Machine Learning Results

| Model | MAE | RMSE | R² |
|---|---:|---:|---:|
| Linear Regression | 2.900 | 4.327 | -0.217 |
| Random Forest | 2.849 | 4.167 | -0.129 |
| XGBoost | 2.997 | 4.593 | -0.371 |
| **Tuned Random Forest** | **2.659** | **3.907** | **0.008** |

**Best model:** Tuned Random Forest.

Best parameters:
- `n_estimators = 200`
- `max_depth = 2`
- `min_samples_leaf = 3`
- `random_state = 42`

## Top 5 Influential Features

1. `strike_rate`
2. `matches_played`
3. `total_sixes`
4. `bowling_economy`
5. `performance_score`

These are model feature-importance results; they do not prove direct cause-and-effect.

## Limitations

The dataset contains only 39 modeling examples, with 31 used for training and 8 for testing. The low R² also shows that performance statistics alone do not explain auction value well in this small dataset. Real auction prices are influenced by factors such as team requirements, player availability, recent form, age, role demand, market conditions, and auction competition.

Therefore, the model should be presented as an academic estimation model rather than a guaranteed real-world auction-price predictor.

## Project Structure

```text
ipl-player-auction-prediction/
├── README.md
├── requirements.txt
├── data/
├── sql/
│   ├── schema.sql
│   ├── data_insert.sql
│   └── queries.sql
├── notebooks/
│   └── ipl_project.ipynb
├── docs/
│   ├── er_diagram.png
│   └── team_owner_report.pdf
└── outputs/
    └── charts/
```

## Author

**Name:** Shaam Prakash S  
**Batch:** AI & DS - Final Year  
**Date:** 10-09-2026
