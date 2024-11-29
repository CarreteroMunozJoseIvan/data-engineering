-- Let's do some analytics, we will find out which player had the best improvement
SELECT 
	player_name,
	season_stats[1] AS first_season,
	season_stats[CARDINALITY(season_stats)] AS latest_season
FROM players_cumulative
WHERE current_season = 2001