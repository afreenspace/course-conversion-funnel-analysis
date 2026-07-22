# Course Conversion Funnel Analysis (SQL)

## About this project

This project was created as part of my SQL learning journey on **365 Data Science**, where I practiced subqueries, joins, and date functions on a real-world student engagement dataset. This repository contains my SQL solution and interpretation for analyzing the engagement→purchase funnel.

## Overview

This project analyzes the student engagement-to-purchase funnel for the 365 Data Science platform using MySQL. The goal is to understand how students move from registration → engagement → paid subscription, and identify where the biggest drop-offs happen.

## Business Questions

1. What is the free-to-paid conversion rate among students who watched a lecture?
2. What is the average duration between the registration date and the date of first-time engagement?
3. What is the average duration between the date of first-time engagement and the date of first-time purchase?
4. How can we interpret these results, and what are their implications?

## Dataset

The `db_course_conversions` database contains 3 tables:

- `student_info` — student_id, date_registered
- `student_engagement` — records of every lecture a student watched
- `student_purchases` — records of every subscription purchase

## Tools Used

- MySQL / MySQL Workbench
- SQL concepts: correlated & uncorrelated subqueries, LEFT JOIN, DATEDIFF, conditional aggregation (CASE + SUM)

## Approach

1. Used grouped subqueries to reduce `student_engagement` and `student_purchases` down to one row per student — each student's **first** engagement date and **first** purchase date.
2. Joined `student_info` to the engagement subquery with an `INNER JOIN` (every student in this analysis must have engaged at least once).
3. Joined the purchase subquery with a `LEFT JOIN` (purchasing is optional — not every engaged student buys).
4. Applied a business rule filter: only count a purchase as valid if it occurred on or after the student's first engagement date, or if they never purchased at all.
5. Verified the result against a provided sanity check (20,255 records) before calculating the final metrics.

## SQL (summary)

```sql
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
```

## Key Results (example)

- Free-to-paid conversion rate: 11.29%
- Avg. days: registration → first engagement: 3.90 days
- Avg. days: first engagement → first purchase: 26.25 days

## Interpretation

- **Conversion rate (11.29%)**: About 1 in 9 students who watch a lecture go on to purchase a subscription.
- **Registration → first engagement (3.90 days)**: Students engage quickly after registering.
- **First engagement → first purchase (26.25 days)**: Students take longer to decide to purchase; opportunity for targeted nurture campaigns.

## What I learned

- Writing subqueries in the `FROM` clause to pre-aggregate data before joining
- Choosing between `INNER JOIN` and `LEFT JOIN` based on whether a relationship is required or optional
- Using `DATEDIFF` to calculate durations between dates
- Using `CASE` inside aggregate functions to calculate conditional percentages
- Translating a Venn diagram / business requirement into the correct join logic

## How to push to GitHub

Run the following from the project folder:

```bash
git branch -M main
git remote add origin https://github.com/afreenspace/course-conversion-funnel-analysis.git
git push -u origin main
```

(You may be prompted for credentials or need to configure SSH.)

---

If you want, I can also add a `LICENSE` file, a short `README` badge, or open the initial PR for you — tell me which you'd like next.
