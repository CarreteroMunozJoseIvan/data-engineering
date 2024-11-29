-- let´s play around with the concepts of Struct & Array
-- We are going to use a table which has all the data from a player by season
-- The problem we have here is that if we join this table with another downstream table, it will cause shuffling and we will lose compression.

SELECT * FROM player_seasons; 

--  We wanna to create a table that has one row per player and has a stats column as an array of values for all seasons. So we remove all the temporal components
-- So, We will create a struct column with its own data tye

-- We'll use this table to remove temorary data
 CREATE TABLE players (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     seasons season_stats[],
	 scoring_class scoring_class[],
     years_since_last_active INTEGER,
     is_active BOOLEAN,
     current_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );

-- We'll use this table to load the data in the format we want and in batches of each season
CREATE TABLE players_cumulative (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     season_stats season_stats[],
	 scoring_class scoring_class,
	 years_since_last_active INTEGER,
	 is_active BOOLEAN,
     current_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );