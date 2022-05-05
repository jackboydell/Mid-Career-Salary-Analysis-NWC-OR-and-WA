-- Final Project - Database
-- Jack Boydell | Paul McSlarrow
DROP TABLE college_data;
CREATE TABLE college_data (
    school_name TEXT PRIMARY KEY,
    private TEXT,
    applications INT,
    apps_accepted INT,
    new_enrollees INT,
    from_top_10perc_HS INT,
    from_top_25perc_HS INT,
    fulltime_students INT,
    parttime_students INT,
    out_of_state_tuitiion INT,
    room_board_costs INT,
    book_costs INT,
    est_personal_spending INT,
    pct_faculty_PHD INT,
    pc_faculty_terminal INT,
    stud_fac_ratio REAL,
    pct_alum_donate INT,
    expend_per_stud INT,
    grad_rate INT
);

COPY college_data
FROM '/Users/jackboydell/Desktop/DATA 403/College_Data.csv'
WITH (FORMAT CSV, HEADER);

UPDATE college_data
SET school_name = 'George Fox University'
WHERE school_name = 'George Fox College';

UPDATE college_data
SET school_name = 'Linfield University'
WHERE school_name = 'Linfield College';

UPDATE college_data
SET school_name = 'Whitworth University'
WHERE school_name = 'Whitworth College';

-- create other tables (constraints) and joins 
CREATE TABLE init_or_schools (
    "rank" TEXT,
    school_name TEXT PRIMARY KEY,
    school_type TEXT,
    early_career_pay TEXT, 
    mid_carrer_pay TEXT,
    per_high_meaning TEXT,
    per_STEM_deg TEXT
);

ALTER TABLE init_or_schools
ADD COLUMN "state" CHAR(2);

UPDATE init_or_schools
SET "state" = 'OR';

CREATE TABLE init_wa_schools (
    "rank" TEXT,
    school_name TEXT PRIMARY KEY ,
    school_type TEXT,
    early_career_pay TEXT, 
    mid_carrer_pay TEXT,
    per_high_meaning TEXT,
    per_STEM_deg TEXT
);

ALTER TABLE init_wa_schools
ADD COLUMN "state" CHAR(2);

UPDATE init_wa_schools
SET "state" = 'WA';

-- loading in Oregon schools
COPY init_or_schools 
FROM '/Users/jackboydell/Desktop/DATA 403/oregon_schools.csv'
WITH (FORMAT CSV, HEADER);

COPY init_wa_schools
FROM '/Users/jackboydell/Desktop/DATA 403/washington_schools.csv'
WITH (FORMAT CSV, HEADER);

--- creating full able using UNION ALL along with formating data appropriately using regular expression functions 
DROP TABLE init_full_table;
CREATE TABLE init_full_table AS (
    SELECT (regexp_split_to_array(rank, 'Rank:'))[2]::INT as "rank",
        (regexp_split_to_array(school_name, 'School\sName:'))[2] as school_name,
        (regexp_split_to_array(school_type, 'School\sType:'))[2] as school_type,
        replace((regexp_split_to_array(early_career_pay, 'Pay:\$'))[2], ',', '')::INT as early_career_pay,
        replace((regexp_split_to_array(mid_carrer_pay, 'Pay:\$'))[2], ',', '')::INT as mid_career_pay,
        per_high_meaning, per_stem_deg, "state"
FROM (
SELECT * FROM init_or_schools  -- utilizing UNION ALL
UNION ALL
SELECT * FROM init_wa_schools) as subquery);

UPDATE init_full_table
SET per_high_meaning = 0
WHERE per_high_meaning ILIKE '%-%';

UPDATE init_full_table
SET per_stem_deg = 0
WHERE per_stem_deg ILIKE '%-%';

UPDATE init_full_table
    SET per_high_meaning = (regexp_match(per_high_meaning, '\d+'))[1]::INT;

UPDATE init_full_table
    SET per_stem_deg = (regexp_match(per_stem_deg, '\d+'))[1]::INT;

ALTER TABLE init_full_table
ADD COLUMN per_high_meaning_int INT,
ADD COLUMN per_stem_deg_int INT;

UPDATE init_full_table
SET per_high_meaning_int = per_high_meaning::INT,
    per_stem_deg_int = per_stem_deg::INT;

ALTER TABLE init_full_table
DROP COLUMN per_high_meaning,
DROP COLUMN per_stem_deg; 

UPDATE init_full_table
SET school_name = 'Linfield University'
WHERE school_name = 'Linfield University-McMinnville Campus';

UPDATE init_full_table
SET school_name = 'Lewis and Clark College'
WHERE school_name = 'Lewis & Clark College';

ALTER TABLE init_full_table
ADD CONSTRAINT ft_foreign_key FOREIGN KEY (school_name) REFERENCES college_data; -- NOT WORKING


-- join college data and select just NWC schools ----------------------------------
DROP TABLE nwc_joined;
CREATE TABLE full_joined AS (
    SELECT * 
    FROM init_full_table as I LEFT JOIN college_data as C
    USING(school_name)
);

CREATE TABLE nwc_joined AS (
    SELECT * FROM full_joined
WHERE school_name ILIKE ANY (array['Willamette%', 'Pacific%University', '%Puget%', 'Whitman%', 'Whitworth University', 
    'Lewis%', '%Fox%', 'Linfield University'])
ORDER BY school_name);

