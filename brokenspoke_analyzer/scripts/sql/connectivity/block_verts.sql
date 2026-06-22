----------------------------------------
-- INPUTS
-- location: neighborhood
--
-- Maps each census block to the network vertices of its road_ids (each road's
-- midpoint vertex). These are the seed vertices for the per-block driving-distance
-- search: every one is wired to a single 0-cost super-source so one Dijkstra yields
-- the minimum-over-the-block's-roads cost to every reachable road -- identical to
-- taking MIN over the block's roads in the old per-road model, but in one search
-- per block instead of one per road.
--
-- A road is only used as a seed if it intersects the analysis boundary. This
-- mirrors the old per-road model, whose reachable_roads_*_calc only ran a search
-- from a road when EXISTS (ST_Intersects(neighborhood_boundary, road)); roads
-- outside the boundary polygon (the network buffer beyond the city) never seeded
-- a trip there, so they must not seed one here either.
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_block_verts;

CREATE TABLE generated.neighborhood_block_verts AS
SELECT
    cb.geoid20,
    v.vert_id
FROM neighborhood_census_blocks AS cb
CROSS JOIN LATERAL unnest(cb.road_ids) AS rid (road_id)
INNER JOIN neighborhood_ways_net_vert AS v ON v.road_id = rid.road_id
INNER JOIN neighborhood_ways AS w ON w.road_id = rid.road_id
WHERE EXISTS (
    SELECT 1
    FROM neighborhood_boundary AS b
    WHERE ST_Intersects(b.geom, w.geom)
);

CREATE INDEX idx_neighborhood_block_verts_geoid
ON generated.neighborhood_block_verts (geoid20);
CREATE INDEX idx_neighborhood_block_verts_vert
ON generated.neighborhood_block_verts (vert_id);
ANALYZE generated.neighborhood_block_verts;
