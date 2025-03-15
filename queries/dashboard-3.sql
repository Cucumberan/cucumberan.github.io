
—retention_ads_organic———

WITH launch_date AS (
    SELECT min(time::DATE) AS start_day
    FROM feed_actions
)
SELECT
    t1.start_day::TEXT AS start_day,
    t2.day::TEXT AS day,
    source,
    COUNT(t1.user_id) AS users
FROM (
    SELECT user_id,
           source,
           min(time::DATE) AS start_day
    FROM feed_actions
    GROUP BY user_id, source
    HAVING min(time::DATE) >= (SELECT start_day + INTERVAL '39 days' FROM launch_date) 
) t1
JOIN (
    SELECT DISTINCT user_id,
                    time::DATE AS day
    FROM feed_actions
) t2 USING (user_id)
WHERE t2.day < '2025-02-10'::DATE
GROUP BY t1.start_day, t2.day, source;
