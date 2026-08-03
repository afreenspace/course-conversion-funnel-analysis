/*
  db_course_conversions.sql
  Cleaned and annotated version of queries used for the Course Conversion Funnel Analysis

  Tables assumed:
  - student_info(student_id, date_registered)
  - student_engagement(student_id, date_watched)
  - student_purchases(student_id, date_purchased)

  Notes:
  - We reduce engagement and purchase tables to the first event per student (MIN(date)).
  - We only count a purchase as valid if it occurs on or after the student's first watch date.
  - Conversion is measured among students who have watched at least one lecture.
*/

-- 1) Sanity check: count of engaged students (matching the provided sanity number)
SELECT COUNT(*) AS engaged_students
FROM student_info si
JOIN (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
  ON si.student_id = se.student_id
LEFT JOIN (
    SELECT student_id, MIN(date_purchased) AS first_date_purchased
    FROM student_purchases
    GROUP BY student_id
) sp
  ON se.student_id = sp.student_id
WHERE sp.first_date_purchased IS NULL
   OR se.first_date_watched <= sp.first_date_purchased;

-- 2) Conversion rate: percent of engaged students who eventually purchased (purchase on/after first watch)
SELECT 
    ROUND(SUM(CASE WHEN sp.first_date_purchased IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate_percent
FROM student_info si
JOIN (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
  ON si.student_id = se.student_id
LEFT JOIN (
    SELECT student_id, MIN(date_purchased) AS first_date_purchased
    FROM student_purchases
    GROUP BY student_id
) sp
  ON se.student_id = sp.student_id
WHERE sp.first_date_purchased IS NULL
   OR se.first_date_watched <= sp.first_date_purchased;

-- 3) Avg days: registration -> first engagement
SELECT 
    ROUND(AVG(DATEDIFF(se.first_date_watched, si.date_registered)), 2) AS avg_days_reg_to_watch
FROM student_info si
JOIN (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
  ON si.student_id = se.student_id;

-- 4) Avg days: first engagement -> first purchase (only students who purchased after watching)
SELECT 
    ROUND(AVG(DATEDIFF(sp.first_date_purchased, se.first_date_watched)), 2) AS avg_days_watch_to_purch
FROM (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
JOIN (
    SELECT student_id, MIN(date_purchased) AS first_date_purchased
    FROM student_purchases
    GROUP BY student_id
) sp
  ON se.student_id = sp.student_id
WHERE se.first_date_watched <= sp.first_date_purchased;

-- 5) Combined summary: conversion and both averages together (applies the business rule)
SELECT 
    ROUND(SUM(CASE WHEN sp.first_date_purchased IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(AVG(DATEDIFF(se.first_date_watched, si.date_registered)), 2) AS av_reg_watch,
    ROUND(AVG(DATEDIFF(sp.first_date_purchased, se.first_date_watched)), 2) AS av_watch_purch
FROM student_info si
JOIN (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
  ON si.student_id = se.student_id
LEFT JOIN (
    SELECT student_id, MIN(date_purchased) AS first_date_purchased
    FROM student_purchases
    GROUP BY student_id
) sp
  ON se.student_id = sp.student_id
WHERE sp.first_date_purchased IS NULL
   OR se.first_date_watched <= sp.first_date_purchased;

-- 6) Example detail row for one student (useful for debugging)
SELECT si.student_id, si.date_registered, se.first_date_watched, sp.first_date_purchased
FROM student_info si
JOIN (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
  ON si.student_id = se.student_id
LEFT JOIN (
    SELECT student_id, MIN(date_purchased) AS first_date_purchased
    FROM student_purchases
    GROUP BY student_id
) sp
  ON se.student_id = sp.student_id
WHERE si.student_id = 268727;
