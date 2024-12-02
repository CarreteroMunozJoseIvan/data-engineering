
WITH season_range AS (
    -- Generar un rango completo de temporadas desde la primera hasta la última temporada de cada jugador
    SELECT
        pc.player_name,
        gs.season AS current_season,
        pc.height,
        pc.college,
        pc.country,
        pc.draft_year,
        pc.draft_round,
        pc.draft_number,
        pc.season_stats, -- Mantener la lista completa de estadísticas
        pc.scoring_class,
        pc.years_since_last_active,
        -- Verificar si la temporada actual está en las listas de stats
        CASE
            WHEN gs.season = ANY(ARRAY(SELECT gs.season FROM UNNEST(pc.season_stats) AS gs(season))) THEN
                (CASE WHEN gs.season = pc.current_season THEN pc.is_active ELSE FALSE END)
            ELSE FALSE
        END AS is_active -- Marcar temporadas como activas o inactivas
    FROM players_cumulative pc
    CROSS JOIN LATERAL (
        SELECT
            generate_series( -- Generar el rango completo de temporadas
                (SELECT MIN(gs.season) FROM UNNEST(pc.season_stats) AS gs(season)), -- Primera temporada
                (SELECT MAX(gs.season) FROM UNNEST(pc.season_stats) AS gs(season))  -- Última temporada
            ) AS season
    ) AS gs
),
aligned_seasons AS (
    -- Alinear scoring_class con temporadas activas e inactivas
    SELECT
        sr.player_name,
        sr.current_season,
        sr.height,
        sr.college,
        sr.country,
        sr.draft_year,
        sr.draft_round,
        sr.draft_number,
        sr.season_stats, -- Mantener el historial completo
        -- Alinear scoring_class con current_season solo para temporadas activas
        CASE
            WHEN sr.is_active THEN sr.scoring_class[array_position(ARRAY(SELECT gs.season FROM UNNEST(sr.season_stats) AS gs(season)), sr.current_season)]
            ELSE NULL -- NULL para temporadas inactivas
        END AS scoring_class,
        sr.years_since_last_active,
        sr.is_active
    FROM season_range sr
)
-- Insertar en players_lab2
INSERT INTO players_lab2 (
    player_name,
    current_season,
    height,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    season_stats,
    scoring_class,
    years_since_last_active,
    is_active
)
SELECT
    player_name,
    current_season,
    height,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    season_stats,
    scoring_class,
    years_since_last_active,
    is_active
FROM aligned_seasons
ON CONFLICT (player_name, current_season) DO NOTHING;

