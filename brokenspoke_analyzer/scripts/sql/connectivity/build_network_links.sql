----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------

---------------
-- add links --
---------------
-- A net_link represents travelling INTO an intersection along one road
-- (the "source") and back OUT along another (the "target"). Rather than
-- enumerating every one_way/end combination as a separate 5-way join with an
-- `int_id IN (from, to)` disjunction (which forces a per-intersection bitmap
-- re-scan of the ways table), build the source/target incidences once and
-- self-join them on int_id.
--
-- A road touches an intersection at intersection_from or intersection_to.
-- It can be a SOURCE (driven toward the intersection) at:
--   intersection_to   if two-way (one_way IS NULL) or 'ft'
--   intersection_from if two-way (one_way IS NULL) or 'tf'
-- It can be a TARGET (driven away from the intersection) at:
--   intersection_from if two-way (one_way IS NULL) or 'ft'
--   intersection_to   if two-way (one_way IS NULL) or 'tf'
-- UNION (not UNION ALL) collapses the duplicate row a two-way self-loop
-- (intersection_from = intersection_to) would otherwise produce.
INSERT INTO received.neighborhood_ways_net_link (
    int_id, source_vert, target_vert, geom
)
WITH src AS (
    SELECT
        roads.intersection_to AS int_id,
        vert.vert_id,
        vert.geom,
        roads.road_id
    FROM received.neighborhood_ways AS roads
    INNER JOIN received.neighborhood_ways_net_vert AS vert
        USING (road_id)
    WHERE roads.one_way IS NULL OR roads.one_way = 'ft'
    UNION
    SELECT
        roads.intersection_from AS int_id,
        vert.vert_id,
        vert.geom,
        roads.road_id
    FROM received.neighborhood_ways AS roads
    INNER JOIN received.neighborhood_ways_net_vert AS vert
        USING (road_id)
    WHERE roads.one_way IS NULL OR roads.one_way = 'tf'
),

tgt AS (
    SELECT
        roads.intersection_from AS int_id,
        vert.vert_id,
        vert.geom,
        roads.road_id
    FROM received.neighborhood_ways AS roads
    INNER JOIN received.neighborhood_ways_net_vert AS vert
        USING (road_id)
    WHERE roads.one_way IS NULL OR roads.one_way = 'ft'
    UNION
    SELECT
        roads.intersection_to AS int_id,
        vert.vert_id,
        vert.geom,
        roads.road_id
    FROM received.neighborhood_ways AS roads
    INNER JOIN received.neighborhood_ways_net_vert AS vert
        USING (road_id)
    WHERE roads.one_way IS NULL OR roads.one_way = 'tf'
)

SELECT
    src.int_id,
    src.vert_id,
    tgt.vert_id, -- noqa: AL08
    ST_Makeline(src.geom, tgt.geom) -- noqa: AL03
FROM src
INNER JOIN tgt
    ON
        src.int_id = tgt.int_id
        AND src.road_id != tgt.road_id;

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
