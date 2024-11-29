INSERT INTO players (
    player_name, height, college, country, draft_year, draft_round, 
    draft_number, seasons, current_season
)
SELECT 
    player_name, height, college, country, draft_year, draft_round, 
    draft_number,
    ARRAY[ROW(season, pts, ast, reb, weight)::season_stats] AS seasons, -- Crea un array con una sola temporada
    season
FROM player_seasons;
