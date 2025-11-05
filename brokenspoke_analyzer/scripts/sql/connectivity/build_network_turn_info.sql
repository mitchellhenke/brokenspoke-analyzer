----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------

--set source and target roads
UPDATE received.neighborhood_ways_net_link
SET
    source_road_id = s_vert.road_id,
    target_road_id = t_vert.road_id
FROM received.neighborhood_ways_net_vert AS s_vert,
    received.neighborhood_ways_net_vert AS t_vert
WHERE
    received.neighborhood_ways_net_link.source_vert = s_vert.vert_id
    AND received.neighborhood_ways_net_link.target_vert = t_vert.vert_id;

--source_road_dir
UPDATE received.neighborhood_ways_net_link
SET
    source_road_dir
    = CASE
        WHEN received.neighborhood_ways_net_link.int_id = road.intersection_to
            THEN 'ft'
        ELSE 'tf'
    END
FROM received.neighborhood_ways AS road
WHERE received.neighborhood_ways_net_link.source_road_id = road.road_id;

--target_road_dir
UPDATE received.neighborhood_ways_net_link
SET
    target_road_dir
    = CASE
        WHEN received.neighborhood_ways_net_link.int_id = road.intersection_to
            THEN 'ft'
        ELSE 'tf'
    END
FROM received.neighborhood_ways AS road
WHERE received.neighborhood_ways_net_link.target_road_id = road.road_id;

--set azimuths and turn angles
UPDATE received.neighborhood_ways_net_link
SET
    source_road_azi = CASE
        WHEN source_road_dir = 'tf'
            THEN
                degrees(
                    ST_Azimuth(
                        ST_LineInterpolatePoint(roads1.geom, 0.5),
                        ST_StartPoint(roads1.geom)
                    )
                )
        ELSE
            degrees(
                ST_Azimuth(
                    ST_LineInterpolatePoint(roads1.geom, 0.5),
                    ST_EndPoint(roads1.geom)
                )
            )
    END,
    target_road_azi = CASE
        WHEN target_road_dir = 'tf'
            THEN
                degrees(
                    ST_Azimuth(
                        ST_StartPoint(roads2.geom),
                        ST_LineInterpolatePoint(roads2.geom, 0.5)
                    )
                )
        ELSE
            degrees(
                ST_Azimuth(
                    ST_EndPoint(roads2.geom),
                    ST_LineInterpolatePoint(roads2.geom, 0.5)
                )
            )
    END
FROM received.neighborhood_ways AS roads1,
    received.neighborhood_ways AS roads2
WHERE
    source_road_id = roads1.road_id
    AND target_road_id = roads2.road_id;

UPDATE received.neighborhood_ways_net_link
SET turn_angle = (target_road_azi - source_road_azi + 360) % 360;

-------------------
-- set turn info --
-------------------
-- assume crossing is true unless proven otherwise
UPDATE received.neighborhood_ways_net_link SET int_crossing = TRUE;

-- set right turns
UPDATE received.neighborhood_ways_net_link
SET int_crossing = FALSE
WHERE link_id = (
    SELECT r.link_id
    FROM received.neighborhood_ways_net_link AS r
    WHERE
        received.neighborhood_ways_net_link.source_road_id = r.source_road_id
        AND received.neighborhood_ways_net_link.int_id = r.int_id
    ORDER BY
        (sin(radians(r.turn_angle)) > 0)::INT DESC,
        CASE
            WHEN sin(radians(r.turn_angle)) > 0
                THEN cos(radians(r.turn_angle))
            ELSE -cos(radians(r.turn_angle))
        END ASC
    LIMIT 1
);

