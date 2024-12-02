
-- Other way of doing, so we will see if the things have changed
-- assuming that we have all the data up to 2021 and for 2022 the record that do not change they can just increase one or for the record that do change we add a new record

WITH last_season_scd AS (
    SELECT 
        player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    FROM players_scd_table
    WHERE current_season = 2021
      AND end_season = 2021
),
historical_scd AS (
    SELECT 
        player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    FROM players_scd_table
    WHERE current_season <= 2021
      AND end_season <= 2021
),
this_season_data AS (
    SELECT 
        player_name,
        scoring_class,
        is_active,
        current_season -- Aseguramos que current_season esté disponible
    FROM players_lab2
    WHERE current_season = 2022
),
unchanged_records AS (
    SELECT 
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ls.start_season,
        ls.end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
        ON ts.player_name = ls.player_name
    WHERE ts.scoring_class = ls.scoring_class
      AND ts.is_active = ls.is_active
),
changed_records AS (
    SELECT 
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season AS start_season, -- Aquí current_season ya existe
        ts.current_season AS end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
        ON ts.player_name = ls.player_name
    WHERE ts.scoring_class <> ls.scoring_class
       OR ts.is_active <> ls.is_active
),
new_records AS (
    SELECT 
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season AS start_season, -- Aquí también usamos current_season
        ts.current_season AS end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
        ON ts.player_name = ls.player_name
    WHERE ls.player_name IS NULL
)
SELECT * FROM historical_scd
UNION ALL
SELECT * FROM unchanged_records
UNION ALL
SELECT * FROM changed_records
UNION ALL
SELECT * FROM new_records;

