SELECT COUNT(*)
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
   
   SELECT 
    ROUND(AVG(DATEDIFF(se.first_date_watched, si.date_registered)), 2) AS avg_days_reg_to_watch
FROM student_info si
JOIN (
    SELECT student_id, MIN(date_watched) AS first_date_watched
    FROM student_engagement
    GROUP BY student_id
) se
    ON si.student_id = se.student_id;
    
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
