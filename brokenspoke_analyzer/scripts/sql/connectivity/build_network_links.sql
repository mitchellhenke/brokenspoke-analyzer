----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------

---------------
-- add links --
---------------
-- two-way to two-way
-- slow
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id IN (roads1.intersection_from, roads1.intersection_to)
    AND ints.int_id IN (roads2.intersection_from, roads2.intersection_to)
    AND roads1.one_way IS NULL
    AND roads2.one_way IS NULL
    AND roads1.road_id != roads2.road_id;

-- two-way to from-to
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id IN (roads1.intersection_from, roads1.intersection_to)
    AND ints.int_id = roads2.intersection_from
    AND roads1.one_way IS NULL
    AND roads2.one_way = 'ft'
    AND roads1.road_id != roads2.road_id;

-- two-way to to-from
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id IN (roads1.intersection_from, roads1.intersection_to)
    AND ints.int_id = roads2.intersection_to
    AND roads1.one_way IS NULL
    AND roads2.one_way = 'tf'
    AND roads1.road_id != roads2.road_id;

-- from-to to two-way
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id = roads1.intersection_to
    AND ints.int_id IN (roads2.intersection_from, roads2.intersection_to)
    AND roads1.one_way = 'ft'
    AND roads2.one_way IS NULL
    AND roads1.road_id != roads2.road_id;

-- from-to to from-to
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id = roads1.intersection_to
    AND ints.int_id = roads2.intersection_from
    AND roads1.one_way = 'ft'
    AND roads2.one_way = 'ft'
    AND roads1.road_id != roads2.road_id;

-- from-to to to-from
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id = roads1.intersection_to
    AND ints.int_id = roads2.intersection_to
    AND roads1.one_way = 'ft'
    AND roads2.one_way = 'tf'
    AND roads1.road_id != roads2.road_id;

-- to-from to two-way
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id = roads1.intersection_from
    AND ints.int_id IN (roads2.intersection_from, roads2.intersection_to)
    AND roads1.one_way = 'tf'
    AND roads2.one_way IS NULL
    AND roads1.road_id != roads2.road_id;

-- to-from to to-from
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id = roads1.intersection_from
    AND ints.int_id = roads2.intersection_to
    AND roads1.one_way = 'tf'
    AND roads2.one_way = 'tf'
    AND roads1.road_id != roads2.road_id;

-- to-from to from-to
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
SELECT
    ints.int_id,
    vert1.vert_id,
    vert2.vert_id, -- noqa: AL08
    ST_Makeline(vert1.geom, vert2.geom) -- noqa: AL03
FROM received.neighborhood_ways_intersections AS ints,
    received.neighborhood_ways_net_vert AS vert1,
    received.neighborhood_ways AS roads1,
    received.neighborhood_ways_net_vert AS vert2,
    received.neighborhood_ways AS roads2
WHERE
    vert1.road_id = roads1.road_id
    AND vert2.road_id = roads2.road_id
    AND ints.int_id = roads1.intersection_from
    AND ints.int_id = roads2.intersection_from
    AND roads1.one_way = 'tf'
    AND roads2.one_way = 'ft'
    AND roads1.road_id != roads2.road_id;

-- index
CREATE INDEX idx_neighborhood_ways_net_vert_road_id
ON received.neighborhood_ways_net_vert (
    road_id
);
CREATE INDEX idx_neighborhood_ways_net_link_int_id
ON received.neighborhood_ways_net_link (
    int_id
);
CREATE INDEX idx_neighborhood_ways_net_link_src_trgt
ON received.neighborhood_ways_net_link (
    source_vert, target_vert
);
CREATE INDEX idx_neighborhood_ways_net_link_src_rdid
ON received.neighborhood_ways_net_link (
    source_road_id
);
CREATE INDEX idx_neighborhood_ways_net_link_tgt_rdid
ON received.neighborhood_ways_net_link (
    target_road_id
);
ANALYZE received.neighborhood_ways_net_link;
