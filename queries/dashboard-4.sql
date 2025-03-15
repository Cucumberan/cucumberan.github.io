——audience per week retention————
  
WITH visits AS (
  SELECT
    user_id,
    ARRAY_AGG(DISTINCT date_trunc('week', time)) AS weeks_visited
  FROM
    feed_actions
  GROUP BY
    user_id
),
expanded_visits AS (
  SELECT
    fa.user_id,
    v.weeks_visited,
    date_trunc('week', fa.time) AS previous_week
  FROM
    feed_actions fa
    JOIN visits v ON fa.user_id = v.user_id
  GROUP BY
    fa.user_id,
    v.weeks_visited,
    previous_week
  ORDER BY
    previous_week
),
statuses AS (
  SELECT
    user_id,
    weeks_visited,
    previous_week,
    CASE
      WHEN NOT EXISTS (SELECT 1 FROM unnest(weeks_visited) week WHERE week = previous_week + INTERVAL '1 week') THEN 'gone'
      WHEN EXISTS (SELECT 1 FROM unnest(weeks_visited) week WHERE week = previous_week - INTERVAL '1 week') THEN 'retained'
      ELSE 'new'
    END AS status
  FROM
    expanded_visits
)

SELECT 
  status,
  previous_week,
  COUNT(DISTINCT user_id) * 
  CASE 
    WHEN status = 'gone' THEN -1
    ELSE 1
  END AS user_count
FROM statuses
GROUP BY status, previous_week
ORDER BY previous_week;
