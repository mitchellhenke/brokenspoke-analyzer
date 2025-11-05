----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------

--set lengths
UPDATE received.neighborhood_ways_net_link
SET
    source_road_length = ST_Length(roads1.geom),
    target_road_length = ST_Length(roads2.geom)
FROM received.neighborhood_ways AS roads1,
    received.neighborhood_ways AS roads2
WHERE
    source_road_id = roads1.road_id
    AND target_road_id = roads2.road_id;

---------------------
-- set link stress --
---------------------
--source_stress
UPDATE received.neighborhood_ways_net_link
SET
    source_stress
    = CASE
        WHEN
            received.neighborhood_ways_net_link.int_id = road.intersection_to
            THEN road.ft_seg_stress
        ELSE road.tf_seg_stress
    END
FROM received.neighborhood_ways AS road
WHERE received.neighborhood_ways_net_link.source_road_id = road.road_id;

--int_stress
UPDATE received.neighborhood_ways_net_link
SET int_stress = roads.ft_int_stress
FROM received.neighborhood_ways AS roads
WHERE
    received.neighborhood_ways_net_link.source_road_id = roads.road_id
    AND source_road_dir = 'ft';

UPDATE received.neighborhood_ways_net_link
SET int_stress = roads.tf_int_stress
FROM received.neighborhood_ways AS roads
WHERE
    received.neighborhood_ways_net_link.source_road_id = roads.road_id
    AND source_road_dir = 'tf';

UPDATE received.neighborhood_ways_net_link
SET int_stress = 1
WHERE NOT int_crossing;;

--target_stress
UPDATE received.neighborhood_ways_net_link
SET
    target_stress
    = CASE
        WHEN received.neighborhood_ways_net_link.int_id = road.intersection_to
            THEN road.tf_seg_stress
        ELSE road.ft_seg_stress
    END
FROM received.neighborhood_ways AS road
WHERE received.neighborhood_ways_net_link.target_road_id = road.road_id;

--link_stress
UPDATE received.neighborhood_ways_net_link
SET link_stress = greatest(source_stress, int_stress, target_stress);

--------------
-- set cost --
--------------
UPDATE received.neighborhood_ways_net_link
SET link_cost = round((source_road_length + target_road_length) / 2);
