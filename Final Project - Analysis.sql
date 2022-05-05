-- Final Project - Analysis 
-- Jack Boydell | Paul McSlarrow

-- Exporting tables to be used in Python analysis.
COPY nwc_joined 
TO '/Users/jackboydell/Desktop/DATA 403/NWC_schools.csv'
WITH (FORMAT CSV, HEADER);

COPY full_joined
TO '/Users/jackboydell/Desktop/DATA 403/or_wash_schools.csv'
WITH (FORMAT CSV, HEADER);

-- SQL analysis:
-- Which NWC schools have a higher than average median mid-career salary for their given state?
WITH cte as (

SELECT school_name, mid_career_pay, state
FROM init_full_table
WHERE state = 'OR' AND mid_career_pay >= (
SELECT AVG(mid_career_pay) FROM init_full_table
WHERE state = 'OR')

UNION ALL

SELECT school_name, mid_career_pay, state
FROM init_full_table 
WHERE state = 'WA' and mid_career_pay >= (
SELECT AVG(mid_career_pay) FROM init_full_table
WHERE state = 'WA')
) 

SELECT cte.school_name, cte.mid_career_pay, cte.state --AVG(.mid_career_pay) OVER(PARTITION BY cte.state)
FROM cte JOIN nwc_joined
USING(school_name)
ORDER BY cte.mid_career_pay DESC;

-- Paul stuff below
ALTER TABLE full_joined
    ADD COLUMN school_size TEXT;

UPDATE full_joined
    SET school_size = 'small'
WHERE full_joined.fulltime_students <= 3000;

UPDATE full_joined
    SET school_size = 'medium'
WHERE full_joined.fulltime_students > 3000 AND full_joined.fulltime_students < 10000;

UPDATE full_joined
    SET school_size = 'large'
WHERE full_joined.fulltime_students >= 10000;

SELECT 
    j.school_name,
    j.school_size,
    ROUND(AVG(j.mid_career_pay) OVER (PARTITION BY j.school_size ORDER BY j.rank DESC) , 0) AS "mid_pay"
FROM full_joined AS j
ORDER BY "mid_pay" DESC
LIMIT 10;

/* Compares WA and OR schools */
SELECT 
    f.state,
    ROUND(AVG(f.pct_faculty_phd), 2) AS "average_PHD",
    ROUND(AVG(f.grad_rate), 2) AS "grad_rate",
    ROUND(AVG(f.mid_career_pay), 2) AS "mid_pay"
FROM full_joined AS f
GROUP BY f.state;

SELECT
    f.state,
    ROUND(AVG(early_career_pay), 0) AS "early_career_pay",
    ROUND(AVG(mid_career_pay), 0)  AS "mid_career_pay"
FROM full_joined AS f
GROUP By f.state;

SELECT 
    c.school_size, 
    ROUND(AVG(c.from_top_10perc_hs), 2) AS "top_10",
    ROUND(AVG(c.from_top_25perc_hs), 2) AS "top_25",
    ROUND((AVG(c.apps_accepted) / AVG(c.applications) * 100), 2) AS "acceptance_rate",
    ROUND(AVG(c.grad_rate), 2) AS "graduation_rate",
    ROUND(AVG(c.out_of_state_tuitiion), 2) AS "out_of_state_tuition"
FROM college_data AS c
GROUP BY c.school_size;










