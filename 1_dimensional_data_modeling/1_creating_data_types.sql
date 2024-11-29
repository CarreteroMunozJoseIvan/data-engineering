-- First things first, Which parts are part of the seasons and which are not?
-- Then, create a struct
 CREATE TYPE season_stats AS (
                         season INTEGER,
                         pts REAL,
                         ast REAL,
                         reb REAL,
                         weight INTEGER
                       );
-- Consider a new table that would be all of the column at a player level and then we will have an array of the season stats
--  watch out! age depends on the seasons
CREATE TYPE scoring_class AS ENUM ('star', 'good', 'average', 'bad')

ALTER TABLE players_cumulative 
ALTER COLUMN scoring_class 
TYPE text[] 
USING ARRAY[scoring_class::scoring_class];