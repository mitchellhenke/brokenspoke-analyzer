----------------------------------------
-- Adjusts functional class on residential
-- and unclassified with bike facilities
-- or multiple travel lanes to be
-- tertiary
----------------------------------------
UPDATE received.neighborhood_ways
SET functional_class = 'tertiary'
WHERE
    functional_class IN ('residential', 'unclassified')
    AND (
        (ft_lanes > 1
         AND tf_lanes > 1)
        OR speed_limit >= 30
    );
