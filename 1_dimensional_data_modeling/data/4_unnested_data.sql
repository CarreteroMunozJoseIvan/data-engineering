WITH unnested AS (

	SELECT player_name,
			UNNEST(season_stats) AS season_stats,
			UNNEST(scoring_class) AS scoring_class
			FROM players_cumulative 
			WHERE player_name = 'Michael Jordan' and current_season = 2002
)
SELECT player_name,
		(season_stats::season_stats).*,
		scoring_class AS scoring_class
FROM unnested


WITH unnested AS (
    SELECT 
        player_name,
        current_season,
        UNNEST(season_stats) AS season_stats, -- Descomponer season_stats
        UNNEST(scoring_class) AS scoring -- Descomponer scoring_class
    FROM players_cumulative
    WHERE current_season = 2001 -- Filtrar por la temporada actual 2001
)
SELECT 
    player_name,
    current_season,
    (season_stats::season_stats).*,
    scoring AS scoring_class
FROM unnested
WHERE 
    (season_stats).season = 2001 -- Asegurarse de que sea la temporada 2001
    AND scoring = 'star' -- Filtrar solo los valores donde scoring_class sea 'star'
ORDER BY pts DESC; -- Ordenar por puntos en orden descendente
