-- goal:let's see how the records changes over time
-- Downside of this query(scan all history) is that it will be more prone to out of memeory and skew error, because when you have scd that change a lot it will blow up the cardenality

-- First, write a query that looks at all the history and then creates one scd record. Then, we´ll take an scd table and build on top of that incrementally
-- Let's calculate the streaks(how long was in a current dimension)
INSERT INTO players_scd_table (
	player_name,
	scoring_class,
	is_active,
	start_season,
	end_season,
	current_season
)
WITH with_previous AS (
    SELECT
        player_name,
        current_season,
        season_stats,
        scoring_class,
        is_active,
        LAG(scoring_class, 1) OVER (PARTITION BY player_name ORDER BY current_season) AS previous_scoring_class,
        LAG(is_active, 1) OVER (PARTITION BY player_name ORDER BY current_season) AS previous_is_active
    FROM players_lab2
    WHERE current_season <= 2021
),
with_indicators AS (
    SELECT
        *,
        CASE
            WHEN scoring_class <> previous_scoring_class THEN 1
            WHEN is_active <> previous_is_active THEN 1
            ELSE 0
        END AS change_indicator
    FROM with_previous
),
with_streaks AS (
    SELECT
        *,
        SUM(change_indicator) OVER (PARTITION BY player_name ORDER BY current_season) AS streak_identifier
    FROM with_indicators
)
SELECT 
    player_name,
	scoring_class,
	is_active,
    MIN(current_season) AS start_season, -- Primera temporada de la racha
    MAX(current_season) AS end_season,   -- Última temporada de la racha
    2021 as current_season
    
FROM with_streaks
GROUP BY 
    player_name, 
    streak_identifier, 
    scoring_class, 
    is_active
ORDER BY 
    player_name, 
    streak_identifier;

select* from players_scd_table

