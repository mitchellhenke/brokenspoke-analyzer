----------------------------------------
-- INPUTS
----------------------------------------

-- set road_ids
UPDATE neighborhood_paths
SET road_ids = array((
    SELECT neighborhood_ways.road_id
    FROM neighborhood_ways
    WHERE neighborhood_ways.path_id = neighborhood_paths.path_id
));

-- index
CREATE INDEX aidx_neighborhood_paths_road_ids ON neighborhood_paths USING gin (
    road_ids
);
ANALYZE neighborhood_paths (road_ids);
