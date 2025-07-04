----------------------------------------
-- INPUTS
-- location: neighborhood
-- proj: :nb_output_srid psql var must be set before running this script,
-- :cluster_tolerance psql var must be set before running this script.
--       e.g. psql -v nb_output_srid=2163 -v cluster_tolerance=50 -f libraries.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_libraries;

CREATE TABLE generated.neighborhood_libraries (
    id SERIAL PRIMARY KEY,
    blockid10 CHARACTER VARYING(15) [],
    osm_id BIGINT,
    library_name TEXT,
    pop_low_stress INT,
    pop_high_stress INT,
    pop_score FLOAT,
    geom_pt GEOMETRY (POINT, :nb_output_srid),
    geom_poly GEOMETRY (MULTIPOLYGON, :nb_output_srid)
);

-- insert polygons
INSERT INTO generated.neighborhood_libraries (
    geom_poly
)
SELECT
    ST_Multi(
        ST_Buffer(
            ST_CollectionExtract(
                unnest(ST_ClusterWithin(way, :cluster_tolerance)), 3
            ),
            0
        )
    )
FROM neighborhood_osm_full_polygon
WHERE amenity = 'library';

-- set points on polygons
UPDATE generated.neighborhood_libraries
SET geom_pt = ST_Centroid(geom_poly);

-- index
CREATE INDEX sidx_neighborhood_libraries_geomply
ON neighborhood_libraries USING gist (
    geom_poly
);
ANALYZE neighborhood_libraries (geom_poly);

-- insert points
INSERT INTO generated.neighborhood_libraries (
    osm_id, library_name, geom_pt
)
SELECT
    osm_id,
    name,
    way
FROM neighborhood_osm_full_point
WHERE
    amenity = 'library'
    AND NOT EXISTS (
        SELECT 1
        FROM neighborhood_libraries AS s
        WHERE ST_Intersects(s.geom_poly, neighborhood_osm_full_point.way)
    );

-- index
CREATE INDEX sidx_neighborhood_libraries_geompt
ON neighborhood_libraries USING gist (
    geom_pt
);
ANALYZE generated.neighborhood_libraries (geom_pt);

-- set blockid10
UPDATE generated.neighborhood_libraries
SET blockid10 = array((
    SELECT cb.blockid10
    FROM neighborhood_census_blocks AS cb
    WHERE
        ST_Intersects(neighborhood_libraries.geom_poly, cb.geom)
        OR ST_Intersects(neighborhood_libraries.geom_pt, cb.geom)
));

-- block index
CREATE INDEX IF NOT EXISTS aidx_neighborhood_libraries_blockid10
ON neighborhood_libraries USING gin (
    blockid10
);
ANALYZE generated.neighborhood_libraries (blockid10);
