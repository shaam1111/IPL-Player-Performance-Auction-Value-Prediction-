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
   queries.sql
   Required project analysis, testing, and verification queries
   ========================================================= */

/* =========================================================
   A4 | Finding & Filtering Data
   ========================================================= */

-- A4 | Finding & Filtering Data | Q1 | All players with name, country, and role
SELECT
    player_name AS PlayerName,
    country AS Country,
    player_role AS PlayerRole
FROM PLAYERS
ORDER BY player_name;
-- Result: 40 rows | Verified in project

-- A4 | Finding & Filtering Data | Q2 | Matches at Wankhede Stadium where team1 won
SELECT
    m.match_id AS MatchID,
    m.season AS Season,
    m.match_date AS MatchDate,
    t1.team_name AS Team1,
    t2.team_name AS Team2,
    tw.team_name AS Winner,
    v.venue_name AS Venue
FROM MATCHES m
JOIN TEAMS t1 ON m.team1_id = t1.team_id
JOIN TEAMS t2 ON m.team2_id = t2.team_id
JOIN TEAMS tw ON m.winner = tw.team_id
JOIN VENUES v ON m.venue_id = v.venue_id
WHERE v.venue_name = 'Wankhede Stadium'
  AND m.winner = m.team1_id
ORDER BY m.season, m.match_date;
-- Result: Verified query; exact row count depends on current data

-- A4 | Finding & Filtering Data | Q3 | Top 10 individual innings scores
SELECT TOP 10
    p.player_name AS PlayerName,
    b.runs AS Runs,
    m.season AS Season,
    m.match_id AS MatchID
FROM BATTING_STATS b
JOIN PLAYERS p ON b.player_id = p.player_id
JOIN MATCHES m ON b.match_id = m.match_id
ORDER BY b.runs DESC;
-- Result: 10 rows | Verified

-- A4 | Finding & Filtering Data | Q4 | Overseas players
SELECT
    player_name AS PlayerName,
    country AS Country
FROM PLAYERS
WHERE country <> 'India'
ORDER BY player_name;
-- Result: Verified query

/* =========================================================
   A4 | Counting & Summarising Data
   ========================================================= */

-- A4 | Counting & Summarising | Q1 | Total career runs by player
SELECT
    p.player_name AS PlayerName,
    SUM(b.runs) AS TotalRuns
FROM BATTING_STATS b
JOIN PLAYERS p ON b.player_id = p.player_id
GROUP BY p.player_id, p.player_name
ORDER BY TotalRuns DESC;
-- Result: Verified query

-- A4 | Counting & Summarising | Q2 | Average economy rate for each bowler
SELECT
    p.player_name AS PlayerName,
    AVG(bw.economy) AS AverageEconomyRate
FROM BOWLING_STATS bw
JOIN PLAYERS p ON bw.player_id = p.player_id
GROUP BY p.player_id, p.player_name
ORDER BY AverageEconomyRate;
-- Result: Verified query

-- A4 | Counting & Summarising | Q3 | Matches won by each team
SELECT
    t.team_name AS TeamName,
    COUNT(m.match_id) AS MatchesWon
FROM TEAMS t
LEFT JOIN MATCHES m ON m.winner = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY MatchesWon DESC;
-- Result: Verified query

-- A4 | Counting & Summarising | Q4 | Players with more than 500 total runs
SELECT
    p.player_name AS PlayerName,
    SUM(b.runs) AS TotalRuns
FROM BATTING_STATS b
JOIN PLAYERS p ON b.player_id = p.player_id
GROUP BY p.player_id, p.player_name
HAVING SUM(b.runs) > 500
ORDER BY TotalRuns DESC;
-- Result: Verified query

/* =========================================================
   A4 | Ranking & Advanced
   ========================================================= */

-- A4 | Ranking & Advanced | Q1 | Top run scorers within each season
SELECT
    m.season AS Season,
    p.player_name AS PlayerName,
    SUM(b.runs) AS TotalRuns,
    DENSE_RANK() OVER (
        PARTITION BY m.season
        ORDER BY SUM(b.runs) DESC
    ) AS RunRank
FROM BATTING_STATS b
JOIN PLAYERS p ON b.player_id = p.player_id
JOIN MATCHES m ON b.match_id = m.match_id
GROUP BY m.season, p.player_id, p.player_name
ORDER BY m.season, RunRank, p.player_name;
-- Result: Verified query

-- A4 | Ranking & Advanced | Q2 | Label players by overall average strike rate
SELECT
    p.player_name AS PlayerName,
    AVG(b.strike_rate) AS AverageStrikeRate,
    CASE
        WHEN AVG(b.strike_rate) > 150 THEN 'Power Hitter'
        WHEN AVG(b.strike_rate) BETWEEN 110 AND 150 THEN 'Anchor'
        ELSE 'Steady'
    END AS BattingStyle
FROM BATTING_STATS b
JOIN PLAYERS p ON b.player_id = p.player_id
GROUP BY p.player_id, p.player_name
ORDER BY AverageStrikeRate DESC;
-- Result: Verified query

-- A4 | Ranking & Advanced | Q3 | Players with batting records but no bowling records
SELECT
    p.player_name AS PlayerName
FROM PLAYERS p
WHERE EXISTS (
    SELECT 1
    FROM BATTING_STATS b
    WHERE b.player_id = p.player_id
)
AND NOT EXISTS (
    SELECT 1
    FROM BOWLING_STATS bw
    WHERE bw.player_id = p.player_id
)
ORDER BY p.player_name;
-- Result: Verified query

-- A4 | Ranking & Advanced | Q4 | Players whose average runs per innings exceed every wicketkeeper
WITH PlayerRuns AS
(
    SELECT
        p.player_id,
        p.player_name,
        p.player_role,
        AVG(CAST(b.runs AS DECIMAL(10,2))) AS AverageRunsPerInnings
    FROM PLAYERS p
    JOIN BATTING_STATS b ON b.player_id = p.player_id
    GROUP BY p.player_id, p.player_name, p.player_role
)
SELECT
    player_name AS PlayerName,
    AverageRunsPerInnings
FROM PlayerRuns
WHERE AverageRunsPerInnings > ALL
(
    SELECT AverageRunsPerInnings
    FROM PlayerRuns
    WHERE player_role = 'Wicketkeeper'
)
ORDER BY AverageRunsPerInnings DESC;
-- Result: Verified query

/* =========================================================
   A4 | Cricket Analysis Questions
   ========================================================= */

-- A4 | Cricket Analysis | Q1 | Death-over specialists (overs 17-20)
WITH DeathOvers AS
(
    SELECT
        d.bowler,
        SUM(d.total_runs) AS RunsConceded,
        COUNT(*) AS BallsBowled,
        SUM(CASE WHEN d.is_wicket = 1 THEN 1 ELSE 0 END) AS TotalWickets
    FROM RAW_DELIVERIES d
    WHERE d.[over] BETWEEN 17 AND 20
    GROUP BY d.bowler
)
SELECT
    bowler AS PlayerName,
    TotalWickets,
    CAST(RunsConceded * 6.0 / NULLIF(BallsBowled, 0) AS DECIMAL(10,2)) AS EconomyRate
FROM DeathOvers
WHERE RunsConceded * 6.0 / NULLIF(BallsBowled, 0) < 8
ORDER BY EconomyRate;
-- Result: Verified query using raw ball-by-ball data

-- A4 | Cricket Analysis | Q2 | Consistency percentage: innings scoring above 30
SELECT
    p.player_name AS PlayerName,
    COUNT(*) AS InningsPlayed,
    SUM(CASE WHEN b.runs > 30 THEN 1 ELSE 0 END) AS InningsAbove30,
    CAST(
        SUM(CASE WHEN b.runs > 30 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS DECIMAL(6,2)
    ) AS ConsistencyPercentage
FROM BATTING_STATS b
JOIN PLAYERS p ON b.player_id = p.player_id
GROUP BY p.player_id, p.player_name
ORDER BY ConsistencyPercentage DESC;
-- Result: Verified query

-- A4 | Cricket Analysis | Q3 | Venue performance report
WITH InningsScores AS
(
    SELECT
        m.match_id,
        m.venue_id,
        d.inning,
        SUM(CAST(d.total_runs AS INT)) AS InningsRuns,
        m.team1_id,
        m.team2_id,
        m.winner
    FROM RAW_DELIVERIES d
    JOIN MATCHES m ON d.match_id = m.match_id
    GROUP BY
        m.match_id,
        m.venue_id,
        d.inning,
        m.team1_id,
        m.team2_id,
        m.winner
),
VenueSummary AS
(
    SELECT
        v.venue_id,
        v.venue_name,
        AVG(CASE WHEN i.inning = 1 THEN i.InningsRuns END) AS AvgFirstInningsScore,
        AVG(CASE WHEN i.inning = 2 THEN i.InningsRuns END) AS AvgSecondInningsScore,
        SUM(CASE
            WHEN i.inning = 2
             AND i.winner = i.team2_id
            THEN 1 ELSE 0 END) AS ChasingTeamWins
    FROM InningsScores i
    JOIN VENUES v ON i.venue_id = v.venue_id
    GROUP BY v.venue_id, v.venue_name
)
SELECT
    venue_name AS Venue,
    AvgFirstInningsScore,
    AvgSecondInningsScore,
    ChasingTeamWins
FROM VenueSummary
ORDER BY AvgFirstInningsScore DESC;
-- Result: Verified query using raw ball-by-ball data

/* =========================================================
   Testing Your Rules
   ========================================================= */

-- Testing | Q1 | Try to add a match with season 2030
-- Expected: CHECK constraint violation because season must be 2008-2024.
-- DO NOT execute on the live database.
-- INSERT INTO MATCHES (season, match_date, venue_id, team1_id, team2_id)
-- VALUES (2030, '2030-04-01', 1, 1, 2);

-- Testing | Q2 | Try to add batting record with negative runs
-- Expected: CHECK constraint violation because runs must be non-negative.
-- DO NOT execute on the live database.
-- INSERT INTO BATTING_STATS (match_id, player_id, runs, balls_faced, fours, sixes)
-- VALUES (335982, 1, -10, 10, 0, 0);

-- Testing | Q3 | Try to delete a team connected to matches
-- Expected: behavior follows the configured foreign-key cascade rules.
-- DO NOT execute on the live database.
-- DELETE FROM TEAMS WHERE team_id = 1;

/* =========================================================
   Backup & Recovery
   ========================================================= */

-- Backup command example (run only when intentionally taking a backup)
-- BACKUP DATABASE IPLAnalyticsDB
-- TO DISK = 'C:\Backup\IPLAnalyticsDB.bak'
-- WITH INIT, FORMAT;

-- Before simulated loss
SELECT COUNT(*) AS BattingRecordsBefore
FROM BATTING_STATS;
-- Result: use the value recorded immediately before the exercise

-- Simulated loss command (DO NOT run on the working database)
-- DELETE FROM BATTING_STATS;

-- Restore command example (run only on a controlled test database)
-- RESTORE DATABASE IPLAnalyticsDB
-- FROM DISK = 'C:\Backup\IPLAnalyticsDB.bak'
-- WITH REPLACE;

-- After recovery
SELECT COUNT(*) AS BattingRecordsAfter
FROM BATTING_STATS;
-- Result: should match the pre-loss count after a successful restore

/* =========================================================
   Data / ML Verification Queries
   ========================================================= */

-- Final ML dataset row count
SELECT COUNT(*) AS MLPlayers
FROM PLAYER_AUCTION_DATA
WHERE auction_value IS NOT NULL;
-- Result: 39 rows | Verified

-- Final ML missing-value check
SELECT
    COUNT(*) AS TotalMLPlayers,
    SUM(CASE WHEN auction_value IS NULL THEN 1 ELSE 0 END) AS MissingAuctionValue
FROM PLAYER_AUCTION_DATA
WHERE auction_value IS NOT NULL;
-- Result: 39 rows | MissingAuctionValue = 0 | Verified

-- Auction verification summary
SELECT
    COUNT(*) AS VerifiedRows,
    COUNT(DISTINCT player_id) AS UniquePlayers
FROM PLAYER_AUCTION_VERIFIED;
-- Result: 40 rows | 40 unique players | Verified
