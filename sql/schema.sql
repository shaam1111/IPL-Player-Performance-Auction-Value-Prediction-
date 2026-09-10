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
   FINAL schema.sql
   Schema-only recreation of the current project database.
   ========================================================= */

/* ---------- VENUES ---------- */
CREATE TABLE dbo.VENUES
(
    venue_id INT IDENTITY(1,1) NOT NULL,
    venue_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    capacity INT NULL,
    country VARCHAR(50) NULL CONSTRAINT DF_VENUES_COUNTRY DEFAULT ('India'),
    CONSTRAINT PK_VENUES PRIMARY KEY (venue_id),
    CONSTRAINT UQ_VENUES_VENUE_NAME UNIQUE (venue_name),
    CONSTRAINT CK_VENUES_CAPACITY CHECK (capacity > 0)
);
GO

/* ---------- TEAMS ---------- */
CREATE TABLE dbo.TEAMS
(
    team_id INT IDENTITY(1,1) NOT NULL,
    team_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    home_venue_id INT NULL,
    CONSTRAINT PK_TEAMS PRIMARY KEY (team_id),
    CONSTRAINT UQ_TEAMS_TEAM_NAME UNIQUE (team_name),
    CONSTRAINT CK_TEAMS_CITY_NOT_EMPTY CHECK (LTRIM(RTRIM(city)) <> '')
);
GO

ALTER TABLE dbo.TEAMS
ADD CONSTRAINT FK_TEAMS_VENUES
FOREIGN KEY (home_venue_id)
REFERENCES dbo.VENUES(venue_id);
GO

/* ---------- MATCHES ---------- */
CREATE TABLE dbo.MATCHES
(
    match_id INT IDENTITY(1,1) NOT NULL,
    season INT NOT NULL,
    city VARCHAR(50) NULL,
    match_date DATE NOT NULL,
    match_type VARCHAR(30) NULL CONSTRAINT DF_MATCHES_MATCH_TYPE DEFAULT ('league'),
    player_of_match VARCHAR(100) NULL,
    venue_id INT NOT NULL,
    team1_id INT NOT NULL,
    team2_id INT NOT NULL,
    toss_winner INT NULL,
    toss_decision VARCHAR(10) NULL,
    winner INT NULL,
    result VARCHAR(30) NULL,
    result_margin INT NULL,
    target_runs INT NULL,
    target_overs DECIMAL(5,2) NULL,
    super_over CHAR(1) NULL CONSTRAINT DF_MATCHES_SUPER_OVER DEFAULT ('N'),
    method VARCHAR(20) NULL,
    umpire1 VARCHAR(100) NULL,
    umpire2 VARCHAR(100) NULL,
    CONSTRAINT PK_MATCHES PRIMARY KEY (match_id),
    CONSTRAINT CK_MATCHES_SEASON CHECK (season BETWEEN 2008 AND 2024)
);
GO

ALTER TABLE dbo.MATCHES
ADD CONSTRAINT FK_MATCHES_VENUE
FOREIGN KEY (venue_id)
REFERENCES dbo.VENUES(venue_id);
GO

ALTER TABLE dbo.MATCHES
ADD CONSTRAINT FK_MATCHES_TEAM1
FOREIGN KEY (team1_id)
REFERENCES dbo.TEAMS(team_id);
GO

ALTER TABLE dbo.MATCHES
ADD CONSTRAINT FK_MATCHES_TEAM2
FOREIGN KEY (team2_id)
REFERENCES dbo.TEAMS(team_id);
GO

/* ---------- PLAYERS ---------- */
CREATE TABLE dbo.PLAYERS
(
    player_id INT IDENTITY(1,1) NOT NULL,
    player_name VARCHAR(100) NOT NULL,
    team_id INT NULL,
    country VARCHAR(50) NULL CONSTRAINT DF_PLAYERS_COUNTRY DEFAULT ('India'),
    player_role VARCHAR(50) NULL,
    matches_played INT NOT NULL CONSTRAINT DF_PLAYERS_MATCHES_PLAYED DEFAULT (0),
    batting_position INT NULL,
    CONSTRAINT PK_PLAYERS PRIMARY KEY (player_id),
    CONSTRAINT CK_PLAYERS_MATCHES_NON_NEGATIVE CHECK (matches_played >= 0),
    CONSTRAINT FK_PLAYERS_TEAMS FOREIGN KEY (team_id)
        REFERENCES dbo.TEAMS(team_id)
        ON DELETE CASCADE
);
GO

/* ---------- BATTING_STATS ---------- */
CREATE TABLE dbo.BATTING_STATS
(
    batting_id INT IDENTITY(1,1) NOT NULL,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    runs INT NULL CONSTRAINT DF_BATTING_STATS_RUNS DEFAULT (0),
    balls_faced INT NULL CONSTRAINT DF_BATTING_STATS_BALLS DEFAULT (0),
    fours INT NULL CONSTRAINT DF_BATTING_STATS_FOURS DEFAULT (0),
    sixes INT NULL CONSTRAINT DF_BATTING_STATS_SIXES DEFAULT (0),
    strike_rate DECIMAL(6,2) NULL,
    CONSTRAINT PK_BATTING_STATS PRIMARY KEY (batting_id),
    CONSTRAINT CK_BATTING_STATS_RUNS_NON_NEGATIVE CHECK (runs >= 0),
    CONSTRAINT CK_BATTING_STATS_BALLS_POSITIVE CHECK (balls_faced > 0),
    CONSTRAINT FK_BATTING_STATS_MATCHES FOREIGN KEY (match_id)
        REFERENCES dbo.MATCHES(match_id)
        ON DELETE CASCADE,
    CONSTRAINT FK_BATTING_STATS_PLAYERS FOREIGN KEY (player_id)
        REFERENCES dbo.PLAYERS(player_id)
);
GO

/* ---------- BOWLING_STATS ---------- */
CREATE TABLE dbo.BOWLING_STATS
(
    bowling_id INT IDENTITY(1,1) NOT NULL,
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    overs DECIMAL(4,1) NULL,
    runs_conceded INT NULL CONSTRAINT DF_BOWLING_STATS_RUNS_CONCEDED DEFAULT (0),
    wickets INT NULL CONSTRAINT DF_BOWLING_STATS_WICKETS DEFAULT (0),
    economy DECIMAL(5,2) NULL,
    maidens INT NOT NULL CONSTRAINT DF_BOWLING_STATS_MAIDENS DEFAULT (0),
    CONSTRAINT PK_BOWLING_STATS PRIMARY KEY (bowling_id),
    CONSTRAINT CK_BOWLING_STATS_OVERS_POSITIVE CHECK (overs > 0),
    CONSTRAINT CK_BOWLING_STATS_ECONOMY_NON_NEGATIVE CHECK (economy >= 0),
    CONSTRAINT FK_BOWLING_STATS_MATCHES FOREIGN KEY (match_id)
        REFERENCES dbo.MATCHES(match_id)
        ON DELETE CASCADE,
    CONSTRAINT FK_BOWLING_STATS_PLAYERS FOREIGN KEY (player_id)
        REFERENCES dbo.PLAYERS(player_id)
);
GO

/* ---------- RAW_MATCHES ---------- */
CREATE TABLE dbo.RAW_MATCHES
(
    id INT NOT NULL,
    season NVARCHAR(50) NOT NULL,
    city NVARCHAR(50) NOT NULL,
    [date] DATE NOT NULL,
    match_type NVARCHAR(50) NOT NULL,
    player_of_match NVARCHAR(50) NOT NULL,
    venue NVARCHAR(100) NOT NULL,
    team1 NVARCHAR(50) NOT NULL,
    team2 NVARCHAR(50) NOT NULL,
    toss_winner NVARCHAR(50) NOT NULL,
    toss_decision NVARCHAR(50) NOT NULL,
    winner NVARCHAR(50) NOT NULL,
    result NVARCHAR(50) NOT NULL,
    result_margin NVARCHAR(50) NULL,
    target_runs NVARCHAR(50) NULL,
    target_overs NVARCHAR(50) NULL,
    super_over NVARCHAR(50) NOT NULL,
    method NVARCHAR(50) NOT NULL,
    umpire1 NVARCHAR(50) NOT NULL,
    umpire2 NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_RAW_MATCHES PRIMARY KEY (id),
    CONSTRAINT CK_RAW_MATCHES_ID_POSITIVE CHECK (id > 0)
);
GO

/* ---------- RAW_DELIVERIES ---------- */
CREATE TABLE dbo.RAW_DELIVERIES
(
    match_id INT NOT NULL,
    inning TINYINT NOT NULL,
    batting_team NVARCHAR(50) NOT NULL,
    bowling_team NVARCHAR(50) NOT NULL,
    [over] TINYINT NOT NULL,
    ball TINYINT NOT NULL,
    batter NVARCHAR(50) NOT NULL,
    bowler NVARCHAR(50) NOT NULL,
    non_striker NVARCHAR(50) NOT NULL,
    batsman_runs TINYINT NOT NULL,
    extra_runs TINYINT NOT NULL,
    total_runs TINYINT NOT NULL,
    extras_type NVARCHAR(50) NULL,
    is_wicket BIT NOT NULL,
    player_dismissed NVARCHAR(50) NOT NULL,
    dismissal_kind NVARCHAR(50) NOT NULL,
    fielder NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_RAW_DELIVERIES PRIMARY KEY (match_id, inning, [over], ball),
    CONSTRAINT CK_RAW_DELIVERIES_VALUES_VALID CHECK
    (
        match_id > 0
        AND inning > 0
        AND [over] >= 0
        AND ball > 0
    )
);
GO

/* ---------- PLAYER_PERFORMANCE_FINAL ---------- */
CREATE TABLE dbo.PLAYER_PERFORMANCE_FINAL
(
    player_id INT NOT NULL,
    player_name VARCHAR(100) NOT NULL,
    total_runs INT NOT NULL,
    total_fours INT NOT NULL,
    total_sixes INT NOT NULL,
    avg_strike_rate FLOAT NOT NULL,
    centuries INT NOT NULL,
    half_centuries INT NOT NULL,
    ducks INT NOT NULL,
    total_wickets INT NOT NULL,
    avg_economy FLOAT NOT NULL,
    maidens INT NOT NULL CONSTRAINT DF_BOWLING_STATS_MAIDENS DEFAULT (0),
    performance_score DECIMAL(10,2) NULL,
    CONSTRAINT PK_PLAYER_PERFORMANCE_FINAL PRIMARY KEY (player_id),
    CONSTRAINT CK_PLAYER_PERFORMANCE_FINAL_SCORE_NON_NEGATIVE CHECK (performance_score >= 0)
);
GO

/* ---------- PLAYER_AUCTION_DATA ---------- */
CREATE TABLE dbo.PLAYER_AUCTION_DATA
(
    player_id INT NOT NULL,
    player_name VARCHAR(100) NOT NULL,
    matches_played INT NOT NULL,
    total_runs INT NOT NULL,
    balls_faced INT NOT NULL,
    total_fours INT NOT NULL,
    total_sixes INT NOT NULL,
    strike_rate DECIMAL(10,2) NOT NULL,
    centuries INT NOT NULL,
    half_centuries INT NOT NULL,
    ducks INT NOT NULL,
    total_wickets INT NOT NULL,
    bowling_economy DECIMAL(18,6) NOT NULL,
    performance_score DECIMAL(18,2) NOT NULL,
    auction_value DECIMAL(18,2) NULL,
    CONSTRAINT PK_PLAYER_AUCTION_DATA PRIMARY KEY (player_id),
    CONSTRAINT CK_PLAYER_AUCTION_DATA_VALUE_NON_NEGATIVE CHECK (auction_value >= 0)
);
GO

/* ---------- PLAYER_AUCTION_VERIFIED ---------- */
CREATE TABLE dbo.PLAYER_AUCTION_VERIFIED
(
    player_id INT NOT NULL,
    player_name VARCHAR(100) NOT NULL,
    auction_year INT NOT NULL,
    auction_value DECIMAL(18,2) NOT NULL,
    source_type VARCHAR(20) NOT NULL,
    CONSTRAINT PK_PLAYER_AUCTION_VERIFIED PRIMARY KEY (player_id),
    CONSTRAINT CK_PLAYER_AUCTION_VERIFIED_VALUE_NON_NEGATIVE CHECK (auction_value >= 0),
    CONSTRAINT CK_PLAYER_AUCTION_VERIFIED_SOURCE_TYPE
        CHECK (source_type IN ('AUCTION', 'RTM', 'U19_DRAFT'))
);
GO

/* ---------- REQUIRED INDEXES ---------- */
CREATE NONCLUSTERED INDEX IX_PLAYERS_PLAYER_NAME
ON dbo.PLAYERS(player_name);
GO

CREATE NONCLUSTERED INDEX IX_MATCHES_SEASON
ON dbo.MATCHES(season);
GO

/* ---------- Optional performance view used in the project ---------- */
CREATE OR ALTER VIEW dbo.PLAYER_PERFORMANCE AS
SELECT
    p.player_id,
    p.player_name,
    ISNULL(b.matches_played, 0) AS matches_played,
    ISNULL(b.total_runs, 0) AS total_runs,
    ISNULL(b.balls_faced, 0) AS balls_faced,
    ISNULL(b.total_fours, 0) AS total_fours,
    ISNULL(b.total_sixes, 0) AS total_sixes,
    CASE
        WHEN ISNULL(b.balls_faced, 0) > 0
        THEN CAST(b.total_runs * 100.0 / b.balls_faced AS DECIMAL(10,2))
        ELSE 0
    END AS strike_rate,
    ISNULL(b.centuries, 0) AS centuries,
    ISNULL(b.half_centuries, 0) AS half_centuries,
    ISNULL(b.ducks, 0) AS ducks,
    ISNULL(w.total_wickets, 0) AS total_wickets,
    ISNULL(w.bowling_economy, 0) AS bowling_economy
FROM dbo.PLAYERS p
LEFT JOIN
(
    SELECT
        player_id,
        COUNT(DISTINCT match_id) AS matches_played,
        SUM(runs) AS total_runs,
        SUM(balls_faced) AS balls_faced,
        SUM(fours) AS total_fours,
        SUM(sixes) AS total_sixes,
        SUM(CASE WHEN runs >= 100 THEN 1 ELSE 0 END) AS centuries,
        SUM(CASE WHEN runs >= 50 AND runs < 100 THEN 1 ELSE 0 END) AS half_centuries,
        SUM(CASE WHEN runs = 0 THEN 1 ELSE 0 END) AS ducks
    FROM dbo.BATTING_STATS
    GROUP BY player_id
) b ON p.player_id = b.player_id
LEFT JOIN
(
    SELECT
        player_id,
        SUM(wickets) AS total_wickets,
        AVG(ISNULL(economy, 0)) AS bowling_economy
    FROM dbo.BOWLING_STATS
    GROUP BY player_id
) w ON p.player_id = w.player_id;
GO

