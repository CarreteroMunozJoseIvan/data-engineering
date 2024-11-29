
DO $$
DECLARE
    year INTEGER := 1995; -- Año inicial
    max_year INTEGER := 2001; -- Año final
BEGIN
    WHILE year <= max_year LOOP
        INSERT INTO players_cumulative (
            player_name, height, college, country, draft_year, draft_round, draft_number, season_stats, scoring_class, years_since_last_active, is_active, current_season
        )
        WITH yesterday AS (
            SELECT 
                player_name AS y_player_name,
                height AS y_height,
                college AS y_college,
                country AS y_country,
                draft_year AS y_draft_year,
                draft_round AS y_draft_round,
                draft_number AS y_draft_number,
                season_stats AS y_seasons,
				years_since_last_active AS y_years_since_last_active,
                current_season AS y_current_season,
					ARRAY(
				    SELECT CASE
				        WHEN (unnested_value).pts > 20 THEN 'star'
				        WHEN (unnested_value).pts > 15 THEN 'good'
				        WHEN (unnested_value).pts > 10 THEN 'average'
				        ELSE 'bad'
				    END
				    FROM unnest(season_stats) AS unnested_value
				) AS y_scoring_class
            FROM players_cumulative
            WHERE current_season = year
        ), 
        today AS (
            SELECT 
                player_name AS t_player_name,
                height AS t_height,
                college AS t_college,
                country AS t_country,
                draft_year AS t_draft_year,
                draft_round AS t_draft_round,
                draft_number AS t_draft_number,
                seasons AS t_seasons,
				years_since_last_active AS t_years_since_last_active,
                current_season AS t_current_season,
                ARRAY(
				    SELECT CASE
				        WHEN (unnested_value).pts > 20 THEN 'star'
				        WHEN (unnested_value).pts > 15 THEN 'good'
				        WHEN (unnested_value).pts > 10 THEN 'average'
				        ELSE 'bad'
				    END
				    FROM unnest(seasons) AS unnested_value
				) AS t_scoring_class
            FROM players
            WHERE current_season = year + 1
        )
        SELECT 
            COALESCE(t_player_name, y_player_name) AS player_name,
            COALESCE(t_height, y_height) AS height,
            COALESCE(t_college, y_college) AS college,
            COALESCE(t_country, y_country) AS country,
            COALESCE(t_draft_year, y_draft_year) AS draft_year,
            COALESCE(t_draft_round, y_draft_round) AS draft_round,
            COALESCE(t_draft_number, y_draft_number) AS draft_number,
            CASE 
                WHEN y_seasons IS NULL THEN t_seasons
                WHEN t_seasons IS NOT NULL THEN y_seasons || t_seasons
                ELSE y_seasons
            END AS season_stats,
            CASE 
                WHEN y_scoring_class IS NULL THEN t_scoring_class
                WHEN t_scoring_class IS NOT NULL THEN y_scoring_class || t_scoring_class
                ELSE y_scoring_class
            END AS scoring_class,
            CASE 
                WHEN t_seasons IS NOT NULL THEN 0
                ELSE y_years_since_last_active + 1
            END AS years_since_last_active,
            CASE
			    -- Verifica directamente si el año actual está en las estadísticas de t_seasons
			    WHEN t_seasons IS NOT NULL AND 
			         EXISTS (
			             SELECT 1
			             FROM unnest(t_seasons) AS unnested_value
			             WHERE (unnested_value).season = year + 1
			         ) THEN TRUE
			    -- Verifica directamente si el año actual está en las estadísticas de y_seasons
			    WHEN y_seasons IS NOT NULL AND 
			         EXISTS (
			             SELECT 1
			             FROM unnest(y_seasons) AS unnested_value
			             WHERE (unnested_value).season = year + 1
			         ) THEN TRUE
			    -- Si no hay datos en el año actual, el jugador no está activo
			    ELSE FALSE
			END AS is_active,
			
            COALESCE(t_current_season, y_current_season + 1) AS current_season
			

        FROM today
        FULL OUTER JOIN yesterday
        ON today.t_player_name = yesterday.y_player_name
        ON CONFLICT (player_name, current_season) DO UPDATE 
        SET 
            height = EXCLUDED.height,
            college = EXCLUDED.college,
            country = EXCLUDED.country,
            draft_year = EXCLUDED.draft_year,
            draft_round = EXCLUDED.draft_round,
            draft_number = EXCLUDED.draft_number,
            season_stats = EXCLUDED.season_stats,
            scoring_class = EXCLUDED.scoring_class,
            years_since_last_active = EXCLUDED.years_since_last_active,
            is_active = EXCLUDED.is_active;

        year := year + 1; -- Avanzar al siguiente año
    END LOOP;
END $$;
