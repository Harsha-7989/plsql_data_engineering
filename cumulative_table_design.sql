-- Tablespace: pg_default

-- DROP TABLESPACE IF EXISTS pg_default;

ALTER TABLESPACE pg_default
  OWNER TO postgres;

  
-- SELECT * FROM player_seasons;

-- CREATE TYPE season_stats AS (
-- 						season INTEGER,
-- 						gp INTEGER,
-- 						pts REAL,
-- 						reb REAL,
-- 						ast REAL
-- 						)
-- DROP TYPE season_stats
CREATE TYPE scoring_class AS ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE players(
			player_name TEXT,
			height TEXT,
			college TEXT,
			country TEXT,
			draft_year TEXT,
			draft_round TEXT,
			draft_number TEXT,
			season_stats season_stats[],
			scoring_class scoring_class,
			years_since_last_season INTEGER,
			current_season INTEGER,
			PRIMARY KEY(player_name, current_season)
			
)

-- DROP TABLE players
-- SELECT MIN(season) FROM player_seasons
INSERT INTO players
WITH yesterday AS(
		SELECT * FROM players
		WHERE current_season = 1997
),	today AS(
			SELECT * FROM player_seasons
			WHERE season = 1998
		)

SELECT 
		COALESCE(t.player_name, y.player_name) AS player_name,
		COALESCE(t.height, y.height) AS height,
		COALESCE(t.college, y.college) AS college,
		COALESCE(t.country, y.country) AS country,
		COALESCE(t.draft_round, y.draft_round) AS draft_round,
		COALESCE(t.draft_number, y.draft_number) AS draft_number,
		COALESCE(t.draft_year, y.draft_year) AS draft_year,
		CASE WHEN y.season_stats IS NULL 
			THEN ARRAY[ROW(
				t.season,
				t.gp,
				t.pts,
				t.reb,
				t.ast
				)::season_stats]
			WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
				t.season,
				t.gp,
				t.pts,
				t.reb,
				t.ast
				)::season_stats]
		ELSE y.season_stats 
		END AS season_stats,
		CASE WHEN t.season is NOT NULL 
		THEN CASE
				WHEN t.pts > 20 THEN 'star'
				WHEN t.pts > 15 THEN 'good'
				WHEN t.pts > 10 THEN 'average'
				ELSE 'bad'
			END::scoring_class
		ELSE y.scoring_class
		END  AS scoring_calss,
		CASE WHEN t.season IS NOT NULL THEN 0
			ELSE y.years_since_last_season + 1
		END AS years_since_last_season,
		COALESCE(t.season, y.current_season + 1) AS current_season
		-- CASE WHEN t.season IS NOT NULL THEN t.season
		-- ELSE y.current_season + 1
		-- END
						
FROM today t FULL OUTER JOIN yesterday y
		ON t.player_name = y.player_name;
		
-- WITH unnested AS (
-- 	SELECT * 
-- 	-- player_name
-- 	-- UNNEST(season_stats) AS season_stats
-- 	FROM players 
-- 	-- where current_season = 1998 
-- 	-- and player_name = 'Allan Houston'
-- 	)
SELECT *
	-- player_name,
	-- season_stats[1].pts AS first_season,
	-- season_stats[CARDINALITY(season_stats)] AS latest_season,

	-- 	-- -- (season_stats::season_stats).pts
	-- 	-- (season_stats::season_stats).*
FROM players;

-- DROP TABLE players