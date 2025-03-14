----DAU/WAU/MAU feed--------

WITH first_visits AS (
    SELECT
        user_id,
        MIN(DATE(time)) AS first_date
    FROM feed_actions
    GROUP BY user_id
),
dau_data AS (
    SELECT
        fa.user_id,
        fv.first_date,
        DATE(fa.time) AS time,
        CASE
            WHEN fv.first_date = DATE(fa.time) THEN 'DAU_new'
            ELSE 'DAU_old'
        END AS dau_type,
        ROW_NUMBER() OVER (PARTITION BY fa.user_id, DATE(fa.time) ORDER BY fa.time) AS row_num
    FROM feed_actions fa
    JOIN first_visits fv ON fa.user_id = fv.user_id
)
SELECT
    user_id,
    first_date,
    time,
    dau_type
FROM dau_data
WHERE row_num = 1
ORDER BY user_id, time;


----number of posts published -----

WITH first_post AS (
    SELECT
        post_id,
        MIN(DATE(time)) AS first_date
    FROM feed_actions
    GROUP BY post_id
),
dau_data AS (
    SELECT
        fa.post_id,
        fv.first_date,
        DATE(fa.time) AS time,
        CASE
            WHEN fv.first_date = DATE(fa.time) THEN 'new'
            ELSE 'old'
        END AS type,
        ROW_NUMBER() OVER (PARTITION BY fa.post_id, DATE(fa.time) ORDER BY fa.time) AS row_num
    FROM feed_actions fa
    JOIN first_post fv ON fa.post_id = fv.post_id
)
SELECT
    post_id,
    first_date,
    time,
    type
FROM dau_data
WHERE row_num = 1
ORDER BY post_id, time;



 ----top 100 posts--------
   
SELECT 
    post_id,
    COUNT(CASE WHEN action = 'view' THEN 1 END) AS views,
    COUNT(CASE WHEN action = 'like' THEN 1 END) AS likes,
    ROUND(
        (COUNT(CASE WHEN action = 'like' THEN 1 END) * 1.0 / NULLIF(COUNT(CASE WHEN action = 'view' THEN 1 END), 0)), 
        4
    ) AS CTR,
    COUNT(DISTINCT user_id) AS "Audience reach"
FROM feed_actions
GROUP BY post_id
ORDER BY views DESC
LIMIT 100;

——posts with action——
WITH first_post AS (
    SELECT
        post_id,
        MIN(DATE(time)) AS first_date
    FROM feed_actions
    GROUP BY post_id
),
dau_data AS (
    SELECT
        fa.post_id,
        fa.action AS action,
        fv.first_date,
        DATE(fa.time) AS time,
        CASE
            WHEN fv.first_date = DATE(fa.time) THEN 'new'
            ELSE 'old'
        END AS type,
        ROW_NUMBER() OVER (PARTITION BY fa.post_id, DATE(fa.time) ORDER BY fa.time) AS row_num
    FROM feed_actions fa
    JOIN first_post fv ON fa.post_id = fv.post_id
)
SELECT
    post_id,
    action,
    first_date,
    time,
    type
FROM dau_data
WHERE row_num = 1
ORDER BY post_id, time;


