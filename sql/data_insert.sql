-- =========================================================
-- IPL Player Performance & Auction Value Prediction
-- Author: Shaam Prakash S
-- Batch: AI & DS - Final Year
-- Date: 10-09-2026
-- =========================================================

USE IPLAnalyticsDB;
GO

/* =========================================================
   IPL Player Performance & Auction Value Prediction
   FINAL data_insert.sql
   
   IMPORTANT:
   1. RAW_MATCHES and RAW_DELIVERIES are the original CSV data.
      Load those two raw tables first using the SSMS Import Wizard.
   2. This script is intended for a fresh/recreated project database.
      Do NOT run it again on an already-populated IPLAnalyticsDB.
   ========================================================= */

/* ---------- TEAMS ---------- */
INSERT INTO dbo.TEAMS (team_name, city)
SELECT team_name, MAX(city) AS city
FROM
(
    SELECT LTRIM(RTRIM(team1)) AS team_name, LTRIM(RTRIM(city)) AS city
    FROM dbo.RAW_MATCHES
    WHERE team1 IS NOT NULL AND LTRIM(RTRIM(team1)) <> ''

    UNION

    SELECT LTRIM(RTRIM(team2)) AS team_name, LTRIM(RTRIM(city)) AS city
    FROM dbo.RAW_MATCHES
    WHERE team2 IS NOT NULL AND LTRIM(RTRIM(team2)) <> ''
) AS all_teams
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.TEAMS t
    WHERE t.team_name = all_teams.team_name
)
GROUP BY team_name;
GO

/* ---------- VENUES ---------- */
INSERT INTO dbo.VENUES (venue_name, city)
SELECT
    LTRIM(RTRIM(r.venue)) AS venue_name,
    MAX(LTRIM(RTRIM(r.city))) AS city
FROM dbo.RAW_MATCHES r
WHERE r.venue IS NOT NULL
  AND LTRIM(RTRIM(r.venue)) <> ''
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.VENUES v
      WHERE v.venue_name = LTRIM(RTRIM(r.venue))
  )
GROUP BY LTRIM(RTRIM(r.venue));
GO

/* ---------- PLAYERS ---------- */
SET IDENTITY_INSERT dbo.PLAYERS ON;

INSERT INTO dbo.PLAYERS
(
    player_id, player_name, team_id, country, player_role,
    matches_played, batting_position
)
VALUES
(1,  'AJ Finch',         NULL, 'Australia',    'Batsman',      0, NULL),
(2,  'AM Rahane',        NULL, 'India',        'Batsman',      0, NULL),
(3,  'AT Rayudu',        NULL, 'India',        'Batsman',      0, NULL),
(4,  'BB McCullum',      NULL, 'New Zealand',  'Batsman',      0, NULL),
(5,  'CA Pujara',        NULL, 'India',        'Batsman',      0, NULL),
(6,  'DPMD Jayawardene', NULL, 'Sri Lanka',    'Batsman',      0, NULL),
(7,  'F du Plessis',     NULL, 'South Africa', 'Batsman',      0, NULL),
(8,  'G Gambhir',        NULL, 'India',        'Batsman',      0, NULL),
(9,  'M Vijay',          NULL, 'India',        'Batsman',      0, NULL),
(10, 'MA Agarwal',       NULL, 'India',        'Batsman',      0, NULL),
(11, 'AB de Villiers',   NULL, 'South Africa', 'Wicketkeeper', 0, NULL),
(12, 'AC Gilchrist',     NULL, 'Australia',    'Wicketkeeper', 0, NULL),
(13, 'KC Sangakkara',    NULL, 'Sri Lanka',    'Wicketkeeper', 0, NULL),
(14, 'KD Karthik',       NULL, 'India',        'Wicketkeeper', 0, NULL),
(15, 'KL Rahul',         NULL, 'India',        'Wicketkeeper', 0, NULL),
(16, 'MS Dhoni',         NULL, 'India',        'Wicketkeeper', 0, NULL),
(18, 'RG Sharma',        NULL, 'India',        'Batsman',      0, NULL),
(19, 'A Mishra',         NULL, 'India',        'Bowler',       0, NULL),
(20, 'A Nehra',          NULL, 'India',        'Bowler',       0, NULL),
(22, 'B Lee',            NULL, 'Australia',    'Bowler',       0, NULL),
(23, 'DL Vettori',       NULL, 'New Zealand',  'Bowler',       0, NULL),
(24, 'DW Steyn',         NULL, 'South Africa', 'Bowler',       0, NULL),
(28, 'SL Malinga',       NULL, 'Sri Lanka',    'Bowler',       0, NULL),
(29, 'AD Mathews',       NULL, 'Sri Lanka',    'All-Rounder',  0, NULL),
(30, 'AD Russell',       NULL, 'West Indies',  'All-Rounder',  0, NULL),
(31, 'CH Gayle',         NULL, 'West Indies',  'All-Rounder',  0, NULL),
(32, 'DJ Bravo',         NULL, 'West Indies',  'All-Rounder',  0, NULL),
(33, 'GJ Maxwell',       NULL, 'Australia',    'All-Rounder',  0, NULL),
(34, 'JH Kallis',        NULL, 'South Africa', 'All-Rounder',  0, NULL),
(35, 'JP Faulkner',      NULL, 'Australia',    'All-Rounder',  0, NULL),
(36, 'KA Pollard',       NULL, 'West Indies',  'All-Rounder',  0, NULL),
(37, 'RA Jadeja',        NULL, 'India',        'All-Rounder',  0, NULL),
(38, 'R Ashwin',         NULL, 'India',        'All-Rounder',  0, NULL),
(39, 'SR Watson',        NULL, 'Australia',    'All-Rounder',  0, NULL),
(40, 'Yuvraj Singh',     NULL, 'India',        'All-Rounder',  0, NULL),
(42, 'YK Pathan',        NULL, 'India',        'All-Rounder',  0, NULL),
(43, 'PA Patel',         NULL, 'India',        'Wicketkeeper', 0, NULL),
(44, 'RV Uthappa',       NULL, 'India',        'Wicketkeeper', 0, NULL),
(45, 'MK Tiwary',        NULL, 'India',        'Batsman',      0, NULL);

SET IDENTITY_INSERT dbo.PLAYERS OFF;
GO

/* ---------- MATCHES ---------- */
SET IDENTITY_INSERT dbo.MATCHES ON;

INSERT INTO dbo.MATCHES
(
    match_id, season, city, match_date, match_type, player_of_match,
    venue_id, team1_id, team2_id, toss_winner, toss_decision,
    winner, result, result_margin, target_runs, target_overs,
    super_over, method, umpire1, umpire2
)
SELECT
    r.id,
    CONVERT(INT, LEFT(LTRIM(RTRIM(r.season)), 4)),
    r.city,
    r.date,
    r.match_type,
    r.player_of_match,
    v.venue_id,
    t1.team_id,
    t2.team_id,
    tw.team_id,
    NULLIF(r.toss_decision, 'NA'),
    w.team_id,
    NULLIF(r.result, 'NA'),
    TRY_CONVERT(INT, NULLIF(r.result_margin, 'NA')),
    TRY_CONVERT(INT, NULLIF(r.target_runs, 'NA')),
    TRY_CONVERT(DECIMAL(10,2), NULLIF(r.target_overs, 'NA')),
    r.super_over,
    NULLIF(r.method, 'NA'),
    r.umpire1,
    r.umpire2
FROM dbo.RAW_MATCHES r
INNER JOIN dbo.TEAMS t1
    ON LTRIM(RTRIM(t1.team_name)) = LTRIM(RTRIM(r.team1))
INNER JOIN dbo.TEAMS t2
    ON LTRIM(RTRIM(t2.team_name)) = LTRIM(RTRIM(r.team2))
INNER JOIN dbo.VENUES v
    ON LTRIM(RTRIM(v.venue_name)) = LTRIM(RTRIM(r.venue))
LEFT JOIN dbo.TEAMS tw
    ON LTRIM(RTRIM(tw.team_name)) = LTRIM(RTRIM(r.toss_winner))
LEFT JOIN dbo.TEAMS w
    ON LTRIM(RTRIM(w.team_name)) = LTRIM(RTRIM(r.winner));

SET IDENTITY_INSERT dbo.MATCHES OFF;
GO

/* ---------- BATTING STATS ---------- */
INSERT INTO dbo.BATTING_STATS
(
    match_id, player_id, runs, balls_faced, fours, sixes, strike_rate
)
SELECT
    d.match_id,
    p.player_id,
    SUM(d.batsman_runs) AS runs,
    SUM(CASE
        WHEN ISNULL(d.extras_type, '') <> 'wides' THEN 1
        ELSE 0
    END) AS balls_faced,
    SUM(CASE WHEN d.batsman_runs = 4 THEN 1 ELSE 0 END) AS fours,
    SUM(CASE WHEN d.batsman_runs = 6 THEN 1 ELSE 0 END) AS sixes,
    CAST(
        CASE
            WHEN SUM(CASE
                WHEN ISNULL(d.extras_type, '') <> 'wides' THEN 1
                ELSE 0
            END) > 0
            THEN SUM(d.batsman_runs) * 100.0 /
                 SUM(CASE
                     WHEN ISNULL(d.extras_type, '') <> 'wides' THEN 1
                     ELSE 0
                 END)
            ELSE 0
        END AS DECIMAL(6,2)
    ) AS strike_rate
FROM dbo.RAW_DELIVERIES d
INNER JOIN dbo.PLAYERS p
    ON LTRIM(RTRIM(p.player_name)) = LTRIM(RTRIM(d.batter))
WHERE d.batter IS NOT NULL
  AND d.batter <> 'NA'
GROUP BY d.match_id, p.player_id;
GO

/* ---------- BOWLING STATS ---------- */
INSERT INTO dbo.BOWLING_STATS
(
    match_id, player_id, overs, runs_conceded, wickets, economy, maidens
)
SELECT
    d.match_id,
    p.player_id,
    CAST(
        SUM(CASE
            WHEN d.extra_runs = 0
                 OR ISNULL(d.extras_type, '') <> 'wides'
            THEN 1 ELSE 0
        END) / 6.0 AS DECIMAL(5,1)
    ) AS overs,
    SUM(d.total_runs) AS runs_conceded,
    SUM(CASE
        WHEN d.is_wicket = 1
         AND d.dismissal_kind NOT IN ('run out','retired hurt','obstructing the field')
        THEN 1 ELSE 0
    END) AS wickets,
    CAST(
        CASE
            WHEN SUM(CASE
                WHEN d.extra_runs = 0
                     OR ISNULL(d.extras_type, '') <> 'wides'
                THEN 1 ELSE 0
            END) > 0
            THEN SUM(d.total_runs) * 6.0 /
                 SUM(CASE
                     WHEN d.extra_runs = 0
                          OR ISNULL(d.extras_type, '') <> 'wides'
                     THEN 1 ELSE 0
                 END)
            ELSE 0
        END AS DECIMAL(6,2)
    ) AS economy,
    SUM(CASE
        WHEN d.batsman_runs = 0 AND d.extra_runs = 0
        THEN 1 ELSE 0
    END) / 6 AS maidens
FROM dbo.RAW_DELIVERIES d
INNER JOIN dbo.PLAYERS p
    ON LTRIM(RTRIM(p.player_name)) = LTRIM(RTRIM(d.bowler))
WHERE d.bowler IS NOT NULL
  AND d.bowler <> 'NA'
GROUP BY d.match_id, p.player_id;
GO

/* ---------- PLAYER PERFORMANCE FINAL ---------- */
INSERT INTO dbo.PLAYER_PERFORMANCE_FINAL
(
    player_id, player_name, total_runs, total_fours, total_sixes,
    avg_strike_rate, centuries, half_centuries, ducks,
    total_wickets, avg_economy, maidens, performance_score
)
SELECT
    p.player_id,
    p.player_name,
    ISNULL(bt.total_runs, 0),
    ISNULL(bt.total_fours, 0),
    ISNULL(bt.total_sixes, 0),
    ISNULL(bt.avg_strike_rate, 0),
    ISNULL(bt.centuries, 0),
    ISNULL(bt.half_centuries, 0),
    ISNULL(bt.ducks, 0),
    ISNULL(bl.total_wickets, 0),
    ISNULL(bl.avg_economy, 0),
    ISNULL(bl.maidens, 0),
    NULL
FROM dbo.PLAYERS p
LEFT JOIN
(
    SELECT
        player_id,
        SUM(runs) AS total_runs,
        SUM(fours) AS total_fours,
        SUM(sixes) AS total_sixes,
        AVG(CAST(strike_rate AS FLOAT)) AS avg_strike_rate,
        SUM(CASE WHEN runs >= 100 THEN 1 ELSE 0 END) AS centuries,
        SUM(CASE WHEN runs >= 50 AND runs < 100 THEN 1 ELSE 0 END) AS half_centuries,
        SUM(CASE WHEN runs = 0 THEN 1 ELSE 0 END) AS ducks
    FROM dbo.BATTING_STATS
    GROUP BY player_id
) bt ON p.player_id = bt.player_id
LEFT JOIN
(
    SELECT
        player_id,
        SUM(wickets) AS total_wickets,
        AVG(CAST(economy AS FLOAT)) AS avg_economy,
        SUM(maidens) AS maidens
    FROM dbo.BOWLING_STATS
    GROUP BY player_id
) bl ON p.player_id = bl.player_id;
GO

/* ---------- PERFORMANCE SCORE ---------- */
UPDATE dbo.PLAYER_PERFORMANCE_FINAL
SET performance_score = CAST(
      (total_runs * 100.0 / NULLIF((SELECT MAX(total_runs) FROM dbo.PLAYER_PERFORMANCE_FINAL), 0)) * 0.40
    + (avg_strike_rate * 100.0 / NULLIF((SELECT MAX(avg_strike_rate) FROM dbo.PLAYER_PERFORMANCE_FINAL), 0)) * 0.15
    + (centuries * 100.0 / NULLIF((SELECT MAX(centuries) FROM dbo.PLAYER_PERFORMANCE_FINAL), 0)) * 0.10
    + (half_centuries * 100.0 / NULLIF((SELECT MAX(half_centuries) FROM dbo.PLAYER_PERFORMANCE_FINAL), 0)) * 0.10
    + (total_wickets * 100.0 / NULLIF((SELECT MAX(total_wickets) FROM dbo.PLAYER_PERFORMANCE_FINAL), 0)) * 0.20
    + (maidens * 100.0 / NULLIF((SELECT MAX(maidens) FROM dbo.PLAYER_PERFORMANCE_FINAL), 0)) * 0.05
    AS DECIMAL(10,2));
GO

/* ---------- VERIFIED AUCTION DATA ---------- */
INSERT INTO dbo.PLAYER_AUCTION_VERIFIED
(player_id, player_name, auction_year, auction_value, source_type)
VALUES
(1,  'AJ Finch',            2022, 1.50,  'AUCTION'),
(2,  'AM Rahane',            2023, 0.50,  'AUCTION'),
(3,  'AT Rayudu',            2022, 6.75,  'AUCTION'),
(4,  'BB McCullum',          2018, 3.60,  'AUCTION'),
(5,  'CA Pujara',            2014, 1.90,  'AUCTION'),
(6,  'DPMD Jayawardene',     2011, 2.50,  'AUCTION'),
(7,  'F du Plessis',         2022, 7.00,  'AUCTION'),
(8,  'G Gambhir',            2018, 2.80,  'AUCTION'),
(9,  'M Vijay',              2020, 2.00,  'AUCTION'),
(10, 'MA Agarwal',           2023, 8.25,  'AUCTION'),
(11, 'AB de Villiers',       2011, 5.06,  'AUCTION'),
(12, 'AC Gilchrist',         2011, 9.00,  'AUCTION'),
(13, 'KC Sangakkara',        2011, 3.50,  'AUCTION'),
(14, 'KD Karthik',           2022, 5.50,  'AUCTION'),
(15, 'KL Rahul',             2018, 11.00, 'AUCTION'),
(16, 'MS Dhoni',             2008, 6.50,  'AUCTION'),
(18, 'RG Sharma',            2011, 9.20,  'AUCTION'),
(19, 'A Mishra',             2018, 4.00,  'AUCTION'),
(20, 'A Nehra',              2016, 5.50,  'AUCTION'),
(22, 'B Lee',                2012, 2.00,  'AUCTION'),
(23, 'DL Vettori',           2011, 5.50,  'AUCTION'),
(24, 'DW Steyn',             2016, 2.30,  'AUCTION'),
(28, 'SL Malinga',           2019, 2.00,  'AUCTION'),
(29, 'AD Mathews',           2015, 7.50,  'AUCTION'),
(30, 'AD Russell',           2018, 8.50,  'RTM'),
(31, 'CH Gayle',             2018, 2.00,  'AUCTION'),
(32, 'DJ Bravo',             2022, 4.40,  'AUCTION'),
(33, 'GJ Maxwell',           2021, 14.25, 'AUCTION'),
(34, 'JH Kallis',            2014, 5.50,  'AUCTION'),
(35, 'JP Faulkner',          2016, 5.50,  'AUCTION'),
(36, 'KA Pollard',           2018, 5.40,  'RTM'),
(37, 'RA Jadeja',            2012, 9.72,  'RTM'),
(38, 'R Ashwin',             2022, 5.00,  'AUCTION'),
(39, 'SR Watson',            2018, 4.00,  'AUCTION'),
(40, 'Yuvraj Singh',         2019, 1.00,  'AUCTION'),
(41, 'V Kohli',              2008, 0.12,  'U19_DRAFT'),
(42, 'YK Pathan',            2019, 1.90,  'AUCTION'),
(43, 'PA Patel',             2018, 0.20,  'AUCTION'),
(44, 'RV Uthappa',           2013, 9.50,  'AUCTION'),
(45, 'MK Tiwary',            2018, 1.00,  'AUCTION');
GO

/* ---------- PLAYER AUCTION DATA ---------- */
INSERT INTO dbo.PLAYER_AUCTION_DATA
(
    player_id, player_name, matches_played, total_runs, balls_faced,
    total_fours, total_sixes, strike_rate, centuries, half_centuries,
    ducks, total_wickets, bowling_economy, performance_score, auction_value
)
SELECT
    pp.player_id,
    pp.player_name,
    pp.matches_played,
    pp.total_runs,
    pp.balls_faced,
    pp.total_fours,
    pp.total_sixes,
    pp.strike_rate,
    pp.centuries,
    pp.half_centuries,
    pp.ducks,
    pp.total_wickets,
    pp.bowling_economy,
    CAST(
        pp.total_runs * 0.40
        + pp.total_wickets * 15
        + pp.total_sixes * 2
        + pp.centuries * 25
        + pp.half_centuries * 8
        + pp.strike_rate * 0.10
        AS DECIMAL(18,2)
    ) AS performance_score,
    NULL AS auction_value
FROM dbo.PLAYER_PERFORMANCE pp;
GO

/* ---------- COPY VERIFIED AUCTION/RTM VALUES ---------- */
UPDATE p
SET p.auction_value = v.auction_value
FROM dbo.PLAYER_AUCTION_DATA p
INNER JOIN dbo.PLAYER_AUCTION_VERIFIED v
    ON p.player_id = v.player_id
WHERE v.source_type IN ('AUCTION', 'RTM');
GO
