----------------------------------------
-- INPUTS
----------------------------------------
UPDATE neighborhood_ways
SET is_unbikeable = FALSE;

UPDATE neighborhood_ways
SET is_unbikeable = TRUE
FROM neighborhood_osm_full_line AS osm
WHERE
    neighborhood_ways.osm_id = osm.osm_id
    AND osm.bicycle = 'no';

UPDATE neighborhood_ways
SET is_unbikeable = TRUE
FROM neighborhood_osm_full_line AS osm
WHERE
    neighborhood_ways.osm_id = osm.osm_id
    AND osm.highway = 'motorway'
    AND (osm.bicycle IS NULL OR osm.bicycle = 'no');
