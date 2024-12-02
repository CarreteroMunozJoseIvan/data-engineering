CREATE TABLE players_lab2 (
     player_name TEXT,
     height TEXT,
     college TEXT,
     country TEXT,
     draft_year TEXT,
     draft_round TEXT,
     draft_number TEXT,
     season_stats season_stats[],
	 scoring_class TEXT,
	 years_since_last_active INTEGER,
	 is_active BOOLEAN,
     current_season INTEGER,
     PRIMARY KEY (player_name, current_season)
 );


 create table players_scd_table
(
	player_name text,
	scoring_class TEXT,
	is_active boolean,
	start_season integer,
	end_season integer,
	current_season INTEGER,
	PRIMARY KEY (player_name, start_season)--Date partition of th data table
);