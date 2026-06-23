----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_output_srid psql var must be set before running this script,
--      e.g. psql -v nb_output_srid=2249 -f build_network.sql
----------------------------------------
DROP TABLE IF EXISTS received.neighborhood_ways_net_vert;
DROP TABLE IF EXISTS received.neighborhood_ways_net_link;

-- create new tables
CREATE TABLE received.neighborhood_ways_net_vert (
    vert_id SERIAL PRIMARY KEY,
    road_id INTEGER,
    vert_cost INTEGER,
    geom GEOMETRY (POINT, :nb_output_srid)
);

CREATE TABLE received.neighborhood_ways_net_link (
    link_id SERIAL PRIMARY KEY,
    int_id INTEGER,
    turn_angle INTEGER,
    int_crossing BOOLEAN,
    int_stress INTEGER,
    source_vert INTEGER,
    source_road_id INTEGER,
    source_road_dir VARCHAR(2),
    source_road_azi INTEGER,
    source_road_length INTEGER,
    source_stress INTEGER,
    target_vert INTEGER,
    target_road_id INTEGER,
    target_road_dir VARCHAR(2),
    target_road_azi INTEGER,
    target_road_length INTEGER,
    target_stress INTEGER,
    link_cost INTEGER,
    link_stress INTEGER,
    geom GEOMETRY (LINESTRING, :nb_output_srid)
);

-- create vertices
INSERT INTO received.neighborhood_ways_net_vert (road_id, geom)
SELECT
    ways.road_id,
    ST_LineInterpolatePoint(ways.geom, 0.5) -- noqa: AL03
FROM received.neighborhood_ways AS ways;

-- index
CREATE INDEX sidx_neighborhood_ways_net_vert_geom
ON received.neighborhood_ways_net_vert USING gist (
    geom
);
CREATE INDEX idx_neighborhood_ways_net_vert_roadid
ON received.neighborhood_ways_net_vert (
    road_id
);
ANALYZE received.neighborhood_ways_net_vert;
