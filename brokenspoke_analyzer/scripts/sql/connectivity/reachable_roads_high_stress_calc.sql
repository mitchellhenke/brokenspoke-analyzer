----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_max_trip_distance and :block_id psql vars must be set before running this script,
--      e.g. psql -v nb_max_trip_distance=2680 -v block_id="'550250012001003'" \
--              -f reachable_roads_high_stress_calc.sql
--
-- Same as the low-stress calc but over the full network (no link_stress filter).
-- One driving-distance search per block from a single 0-cost super-source wired
-- to all of the block's road vertices, yielding the minimum-over-the-block's-roads
-- cost to every reachable road.
----------------------------------------
INSERT INTO generated.neighborhood_reachable_roads_high_stress (
    source_block,
    target_road,
    total_cost
)
SELECT
    :block_id,
    v.road_id, -- noqa: AL08
    ROUND(MIN(sheds.agg_cost))
FROM PGR_DRIVINGDISTANCE(
    '
        SELECT link_id AS id,
               source_vert AS source,
               target_vert AS target,
               link_cost AS cost
        FROM   neighborhood_ways_net_link
        WHERE  ST_DWithin(geom, (SELECT geom FROM neighborhood_census_blocks WHERE geoid20 = ''' || :block_id || '''), ' || :nb_max_trip_distance + 100 || ')
        UNION ALL
        SELECT -row_number() OVER () AS id, -1 AS source, vert_id AS target, 0 AS cost
        FROM   generated.neighborhood_block_verts
        WHERE  geoid20 = ''' || :block_id || '''',
    -1,
    :nb_max_trip_distance,
    directed := true -- noqa: RF02
) AS sheds
INNER JOIN neighborhood_ways_net_vert AS v ON v.vert_id = sheds.node
GROUP BY v.road_id;
