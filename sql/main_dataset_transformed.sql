--##Core SQL Transformation  
-- Here is the main query used to compute **evolution metrics** for sleep and stress:  

```sql
WITH sessions_ratio AS (
  SELECT
    participant_id,
    activity_type,
    COUNT(*) AS nb_sessions,
    COUNT(*) OVER(PARTITION BY participant_id) AS total_sessions,
    COUNT(*) * 1.0 / COUNT(*) OVER(PARTITION BY participant_id) AS activity_ratio
  FROM `swimwell.Health_fitness.health_fitness_dataset_main`
  GROUP BY participant_id, activity_type
),

valid_participants AS (
  SELECT participant_id, activity_type
  FROM sessions_ratio
  WHERE activity_type IN ('Swimming','Running','Weight Training','Dancing',
                          'Tennis','HIIT','Walking','Basketball','Yoga','Cycling')
    AND activity_ratio >= 0.15
    AND nb_sessions >= 1
),

ranked AS (
  SELECT
    m.*,
    ROW_NUMBER() OVER(PARTITION BY m.participant_id, m.activity_type ORDER BY m.date) AS rn_asc,
    ROW_NUMBER() OVER(PARTITION BY m.participant_id, m.activity_type ORDER BY m.date DESC) AS rn_desc
  FROM `swimwell.Health_fitness.health_fitness_dataset_main` m
  JOIN valid_participants v
    ON m.participant_id = v.participant_id
   AND m.activity_type = v.activity_type
),

averages AS (
  SELECT
    participant_id,
    activity_type,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    AVG(IF(rn_asc <= 7, sleep_hours, NULL)) AS sleep_start,
    AVG(IF(rn_desc <= 7, sleep_hours, NULL)) AS sleep_end,
    AVG(IF(rn_asc <= 7, stress_level, NULL)) AS stress_start,
    AVG(IF(rn_desc <= 7, stress_level, NULL)) AS stress_end
  FROM ranked
  GROUP BY participant_id, activity_type
  HAVING DATE_DIFF(MAX(date), MIN(date), DAY) >= 30
),

evolution AS (
  SELECT
    *,
    sleep_end - sleep_start AS delta_sleep,
    stress_end - stress_start AS delta_stress,
    CASE WHEN sleep_start < 5 THEN "Bad sleeper"
         WHEN sleep_start BETWEEN 5 AND 6 THEN "Average sleeper"
         WHEN sleep_start > 6 THEN "Good sleeper"
         ELSE "Unknown" END AS sleep_quality_start,
    CASE WHEN sleep_end < 5 THEN "Bad sleeper"
         WHEN sleep_end BETWEEN 5 AND 6 THEN "Average sleeper"
         WHEN sleep_end > 6 THEN "Good sleeper"
         ELSE "Unknown" END AS sleep_quality_end,
    CASE WHEN sleep_end > sleep_start THEN "Improved"
         WHEN sleep_end < sleep_start THEN "Worsened"
         ELSE "No change" END AS sleep_quality_change,
    CASE WHEN stress_start < 5 THEN "Non stressed"
         WHEN stress_start BETWEEN 5 AND 6 THEN "Tendency to stress"
         WHEN stress_start > 6 THEN "Highly stressed"
         ELSE "Unknown" END AS stress_level_start,
    CASE WHEN stress_end < 5 THEN "Non stressed"
         WHEN stress_end BETWEEN 5 AND 6 THEN "Tendency to stress"
         WHEN stress_end > 6 THEN "Highly stressed"
         ELSE "Unknown" END AS stress_level_end,
    CASE WHEN stress_end < stress_start THEN "Improved"
         WHEN stress_end > stress_start THEN "Worsened"
         ELSE "No change" END AS stress_level_change
  FROM averages
)

SELECT
  m.*,
  e.first_date,
  e.last_date,
  e.sleep_start,
  e.sleep_end,
  e.delta_sleep,
  e.sleep_quality_start,
  e.sleep_quality_end,
  e.sleep_quality_change,
  e.stress_start,
  e.stress_end,
  e.delta_stress,
  e.stress_level_start,
  e.stress_level_end,
  e.stress_level_change
FROM `swimwell.Health_fitness.health_fitness_dataset_main` m
LEFT JOIN evolution e
  ON m.participant_id = e.participant_id
 AND m.activity_type = e.activity_type;
