CREATE DATABASE glassdoor


CREATE TABLE job_data
(
index INT,
job_title TEXT,
salary_estimate TEXT,
job_description TEXT,
rating DECIMAL(2,1),
company_name TEXT,
location TEXT,
headquarters TEXT,
size TEXT,
founded TEXT,
type_of_ownership TEXT,
industry TEXT,
sector TEXT,
revenue TEXT,
competitors TEXT)

copy job_data
(
index ,
job_title ,
salary_estimate ,
job_description ,
rating ,
company_name ,
location ,
headquarters ,
size ,
founded ,
type_of_ownership ,
industry ,
sector ,
revenue ,
competitors )
FROM  'C:\Users\User\OneDrive\Desktop\Data Analyst\SQL_project\DataCleaning\Uncleaned_DS_jobs.csv'
DELIMITER ',' CSV HEADER;



SELECT * FROM job_data

-- MAKE COPY OF RAW DAYA
CREATE table job_data_copy
(LIKE job_data INCLUDING ALL)

SELECT  * FROM job_data_copy


INSERT INTO job_data_copy
SELECT  * FROM job_data

-- 1. check duplicate
WITH duplicate_cte AS(
SELECT 
    *,
    ROW_NUMBER()OVER(PARTITION BY 
job_title ,
salary_estimate ,
job_description ,
rating ,
company_name ,
location ,
headquarters ,
size ,
founded ,
type_of_ownership ,
industry ,
sector ,
revenue ,
competitors) as row_num
 FROM 
    job_data_copy
)

SELECT 
    *
FROM
    duplicate_cte 
WHERE row_num > 1;





CREATE table job_data_staging
(LIKE job_data_copy INCLUDING ALL)

INSERT INTO job_data_staging
WITH duplicate_cte AS(
SELECT 
    *,
    ROW_NUMBER()OVER(PARTITION BY 
job_title ,
salary_estimate ,
job_description ,
rating ,
company_name ,
location ,
headquarters ,
size ,
founded ,
type_of_ownership ,
industry ,
sector ,
revenue ,
competitors) as row_num
 FROM 
    job_data_copy
)

SELECT 
    INDEX,job_title ,
salary_estimate ,
job_description ,
rating ,
company_name ,
location ,
headquarters ,
size ,
founded ,
type_of_ownership ,
industry ,
sector ,
revenue ,
competitors
FROM
    duplicate_cte 
WHERE row_num = 1;


SELECT * FROM job_data_staging -- number of row was reduced to 659, that meant duplicate has been removed

SELECT COUNT(*), job_title,job_description,company_name
FROM job_data_copy
GROUP BY job_title,job_description,company_name
HAVING COUNT(*)>1



-- 2. STANDARDIZE

--- 2.1 salary_estimate

SELECT 
    salary_estimate,TRIM(TRAILING '(Glassdoor est.)'  FROM salary_estimate)
FROM
    job_data_staging

UPDATE job_data_staging
SET salary_estimate = TRIM(TRAILING '(Glassdoor est.)'  FROM salary_estimate)

SELECT 
    salary_estimate,TRIM(TRAILING '(Employ'  FROM salary_estimate)
FROM
    job_data_staging

UPDATE job_data_staging
SET salary_estimate = TRIM(TRAILING '(Employ'  FROM salary_estimate)

SELECT DISTINCT 
    salary_estimate
FROM 
    job_data_staging
    -- the data was in range, i will convert it to specific value by using median
    --- I will remove $ and K first to beable to change datatype from TEXT to Int
    --- after that we will use min an max in this range to calculate MEDIAN
SELECT 
    salary_estimate,TRIM('$'  FROM salary_estimate)
FROM
    job_data_staging

UPDATE job_data_staging
SET salary_estimate = TRIM('$'  FROM salary_estimate)

SELECT 
    salary_estimate,REPLACE(salary_estimate, '$' , '' )
FROM
    job_data_staging

UPDATE job_data_staging
SET salary_estimate = REPLACE(salary_estimate, '$' , '' )

SELECT 
    salary_estimate,REPLACE(salary_estimate, 'K' , '000' )
FROM
    job_data_staging

UPDATE job_data_staging
SET salary_estimate = REPLACE(salary_estimate, 'K' , '000' )



SELECT
    salary_estimate,
    (CAST(SPLIT_PART(salary_estimate , '-', 1) as INTEGER) + CAST(SPLIT_PART(salary_estimate , '-', 2) as INTEGER))/ 2 AS  median_salary
FROM
    job_data_staging

UPDATE job_data_staging
SET salary_estimate = (CAST(SPLIT_PART(salary_estimate , '-', 1) as INTEGER) + CAST(SPLIT_PART(salary_estimate , '-', 2) as INTEGER))/ 2

SELECT
    salary_estimate
FROM
    job_data_staging --checking whether my query work properly or not

SELECT
    salary_estimate
FROM
    job_data_staging 

UPDATE job_data_staging
SET salary_estimate = cast(salary_estimate AS INT)

    
ALTER TABLE job_data_staging
ALTER COLUMN salary_estimate TYPE INTEGER USING salary_estimate :: INTEGER


ALTER TABLE job_data_staging
RENAME COLUMN salary_estimate TO  "salary_estimate_($)"


ALTER TABLE job_data_staging
RENAME COLUMN "salary_estimate_($)" TO  "Median_salary ($)"

ALTER TABLE job_data_staging
RENAME COLUMN "Median_salary ($)" TO  "median_yearly_salary_($)"

SELECT
    *
FROM
    job_data_staging 

--- 2.2 company_name
SELECT DISTINCT company_name , rating , REGEXP_REPLACE(company_name, '\d\.\d', '')
FROM job_data_staging --- there was a number of rating score behind almost every company name

UPDATE job_data_staging
SET company_name  = REGEXP_REPLACE(company_name, '\d\.\d', '')

SELECT DISTINCT company_name
FROM job_data_staging
ORDER BY company_name

--- 2.3 location
SELECT DISTINCT location , SUBSTRING(location FROM POSITION(',' IN location)+2)
FROM job_data_staging
WHERE location LIKE '%,%' AND location <> 'Patuxent, Anne Arundel, MD' --- some location contain only state not the city and some has two comma

ALTER TABLE job_data_staging
DROP COLUMN state --- use this query when you want to reset the column or something go wrong

ALTER TABLE job_data_staging
ADD COLUMN state TEXT

UPDATE job_data_staging 
SET state= SUBSTRING(location FROM POSITION(',' IN location)+2)
WHERE location LIKE '%,%' AND location <> 'Patuxent, Anne Arundel, MD'

UPDATE job_data_staging 
SET state= 'MD'
WHERE location = 'Patuxent, Anne Arundel, MD'


UPDATE job_data_staging 
SET state= 'MD'
WHERE location = 'Patuxent, Anne Arundel, MD'

SELECT DISTINCT location , state
FROM job_data_staging
WHERE location = 'Patuxent, Anne Arundel, MD'

---- texas 
UPDATE job_data_staging 
SET state= 'TX'
WHERE location ILIKE'texas'

SELECT DISTINCT location , state
FROM job_data_staging
WHERE location ILIKE'texas'


---- United State 
SELECT DISTINCT location , state
FROM job_data_staging
WHERE location ILIKE 'United State%'

UPDATE job_data_staging 
SET state= 'USA'
WHERE location ILIKE 'United State%'

---- utah 
SELECT DISTINCT location , state
FROM job_data_staging
WHERE location ILIKE 'utah'

UPDATE job_data_staging 
SET state= 'UT'
WHERE location ILIKE 'utah'

--- NEW JERSEY
SELECT DISTINCT location , state
FROM job_data_staging
WHERE location ILIKE '%ew%se%'

UPDATE job_data_staging 
SET state= 'NJ'
WHERE location ILIKE '%ew%se%'


--- California
SELECT DISTINCT location , state
FROM job_data_staging
WHERE location ILIKE 'California'

UPDATE job_data_staging 
SET state= 'CA'
WHERE location ILIKE 'California'

----- REMOVE , STATE
SELECT DISTINCT location , REGEXP_REPLACE(location,',.*','')
FROM job_data_staging
ORDER BY location

UPDATE job_data_staging
SET location = REGEXP_REPLACE(location,',.*','')

SELECT *
FROM job_data_staging

-----2.4 SIZE WILL SEPERATE INTO 4 TIER BASED ON NUMBER OF EMPLOYEES
SELECT
     size , REPLACE(size , 'employees' ,'')
FROM
    job_data_staging

SELECT Distinct size , REPLACE(size , 'to' ,'-')
FROM
    job_data_staging
ORDER BY 
    size 

SELECT Distinct size , REPLACE(size , '+' ,'')
FROM
    job_data_staging
ORDER BY 
    size 

    
SELECT Distinct size , 
        LENGTH(size) ,
         TRIM(size) , 
         LENGTH(TRIM(size)),
         REPLACE(size,' ',''),
FROM
    job_data_staging
ORDER BY 
    size 


SELECT DISTINCT size
FROM job_data_staging
WHERE size ILIKE 'unknown' or size = '-1'

UPDATE job_data_staging
SET  size = REPLACE(size , 'employees' ,'')

UPDATE job_data_staging
SET    size = REPLACE(size , 'to' ,'-')

UPDATE job_data_staging
SET    size = REPLACE(size , '+' ,'')

UPDATE job_data_staging
SET size = TRIM(size)

UPDATE job_data_staging
SET size = REPLACE(size,' ','')

UPDATE Job_data_staging
SET size = null
WHERE size ILIKE 'unknown' or size = '-1'

/* Tier 1 (Small) 1–50
Tier 2 (Medium) 51–500
Tier 3 (Large) 501–5,000
Tier 4 (Enterprise) 5,001+*/
SELECT size, 
    CASE
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) BETWEEN 1 AND 50  THEN 'Small'
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) BETWEEN 51 AND 500  THEN 'Medium'
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) BETWEEN 501 AND 5000  THEN 'Large'
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) >= 5001  THEN 'Enterprise'
        ELSE NULL
        END business_size
FROM
    job_data_staging
ORDER BY size

UPDATE job_data_staging
SET SIZE = CASE
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) BETWEEN 1 AND 50  THEN 'Small'
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) BETWEEN 51 AND 500  THEN 'Medium'
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) BETWEEN 501 AND 5000  THEN 'Large'
        WHEN CAST(SPLIT_PART(SIZE,'-' , 1) AS INTEGER) >= 5001  THEN 'Enterprise'
        ELSE NULL
        END 


SELECT a.size ,b.size
FROM job_data_staging a
JOIN job_data_copy b 
    ON a.index = b.index
ORDER BY a.size ---- check by compare to original table

SELECT * FROM Job_data_staging


-----2.5 FOUNDED
SELECT 
    founded , EXTRACT(YEAR FROM (TO_DATE(founded , 'YYYY')))
FROM
    job_data_staging
ORDER BY founded

UPDATE job_data_staging
SET founded = EXTRACT(YEAR FROM (TO_DATE(founded , 'YYYY')))

ALTER TABLE job_data_staging
ALTER COLUMN founded TYPE DATE USING TO_DATE(founded, 'YYYY'); --- THE DATA COME OUT AS FULL DATE FORMAT ex. '1990-01-01', seem like postgres don't allow to contain only year , we will change column to integer



ALTER TABLE job_data_staging
ALTER COLUMN founded TYPE TEXT

SELECT founded ,  EXTRACT(YEAR FROM CAST(founded AS DATE))
FROM
    job_data_staging

UPDATE job_data_staging
SET founded = EXTRACT(YEAR FROM CAST(founded AS DATE))


SELECT founded
FROM
    job_data_staging

ALTER TABLE job_data_staging
ALTER COLUMN founded TYPE INTEGER USING founded :: INTEGER


--- will add new column of year the date data was obtained - founded year, to see how long company was founded

ALTER TABLE job_data_staging
ADD  company_age INT

WITH company_age_cte AS
    (
    SELECT founded , 2020-"founded" AS age
    FROM
    job_data_staging
    WHERE founded <> -1
    )

UPDATE job_data_staging
SET company_age = b.age
FROM company_age_cte b 
WHERE job_data_staging.founded = b.founded  --- POSTGRES DON'T ALLOW ALIAS ON UPDATE AND SET OR TARGET TABLE


SELECT company_age,founded
FROM Job_data_staging

-----2.5 Revenue
SELECT type_of_ownership,industry,SECTOR,revenue
FROM    job_data_staging
WHERE type_of_ownership = '-1' OR  industry = '-1' OR  SECTOR = '-1' OR revenue = '-1'

UPDATE job_data_staging
SET type_of_ownership = NULL ,industry = NULL  ,SECTOR = NULL ,revenue = NULL 
WHERE type_of_ownership = '-1' OR  industry = '-1' OR  SECTOR = '-1' OR revenue = '-1'

SELECT a.revenue,a.size, b.revenue,b.size
FROM    job_data_staging a
JOIN    job_data_staging b 
        ON a.revenue = b.revenue 
WHERE a.size IS NULL AND  b.size is NOT NULL

/* revenue has lost of unknown column and null value  that is null an unknown,
 and data can't not be use to impute POPULATE SIZE , we will remove this afterward */

-- 2.6 type_of_ownership
SELECT  DISTINCT type_of_ownership 
FROM    job_data_staging



SELECT  type_of_ownership , TRIM('Organization' FROM type_of_ownership)
FROM    job_data_staging

UPDATE   job_data_staging
SET type_of_ownership = TRIM('Organization' FROM type_of_ownership)
WHERE   type_of_ownership ILIKE '%onprofit organizatio%'




SELECT  type_of_ownership , TRIM(TRAILING 'Organization' FROM type_of_ownership)
FROM    job_data_staging
WHERE   type_of_ownership ILIKE '%ther organizatio%'

UPDATE   job_data_staging
SET type_of_ownership = TRIM(TRAILING 'Organization' FROM type_of_ownership)
WHERE    type_of_ownership ILIKE '%ther organizatio%'




SELECT  type_of_ownership , REPLACE(type_of_ownership,'Company - Public', 'Public Company')
FROM    job_data_staging
WHERE   type_of_ownership ILIKE '%ompany - Publi%'

UPDATE   job_data_staging
SET type_of_ownership = REPLACE(type_of_ownership,'Company - Public', 'Public Company')
WHERE    type_of_ownership ILIKE '%ompany - Publi%'




SELECT  type_of_ownership , REPLACE(type_of_ownership,'Company - Private', 'Private Company')
FROM    job_data_staging
WHERE   type_of_ownership ILIKE '%ompany - Privat%'

UPDATE   job_data_staging
SET type_of_ownership = REPLACE(type_of_ownership,'Company - Private', 'Private Company')
WHERE    type_of_ownership ILIKE '%ompany - Privat%'




SELECT  type_of_ownership , REPLACE(type_of_ownership,'College / University', 'College')
FROM    job_data_staging
WHERE   type_of_ownership ILIKE '%ollege%univers%'

UPDATE   job_data_staging
SET type_of_ownership = REPLACE(type_of_ownership,'College / University', 'College')
WHERE    type_of_ownership ILIKE '%ollege%univers%'



SELECT  type_of_ownership , TRIM(TRAILING 'or Business Segment' FROM type_of_ownership)
FROM    job_data_staging
WHERE   type_of_ownership ILIKE '%ubsidiary%'

UPDATE   job_data_staging
SET type_of_ownership = TRIM(TRAILING 'or Business Segment' FROM type_of_ownership)
WHERE    type_of_ownership ILIKE '%ubsidiary%'



SELECT  type_of_ownership , TRIM(TRAILING ' / Firm' FROM type_of_ownership)
FROM    job_data_staging
WHERE   type_of_ownership ILIKE '%rivate Practic%'


UPDATE   job_data_staging
SET type_of_ownership = TRIM(TRAILING ' / Firm' FROM type_of_ownership)
WHERE    type_of_ownership ILIKE '%rivate Practic%'


--2.7  industry
SELECT DISTINCT industry
FROM   job_data_staging
ORDER BY industry

--2.8 sector
SELECT DISTINCT sector
FROM   job_data_staging
ORDER BY sector

--2.9 JOB_TITLE 
  --- we will categorize jobtitle in to 1.Data Analyst 2.Business Analyst 3.Data Scientist 4.Data Engineer 
  --- 5.Senior Data Analyst 6.Senior Business Analyst 7.Senior Data Scientist 8.Senior Data Engineer 9.Software Engineer 10.Machine learning Engineer


--- Firstly, we check distinct value, find where is the major data fall into.
SELECT DISTINCT job_title 
FROM   job_data_staging
ORDER BY job_title


SELECT job_title , COUNT(*)
FROM   job_data_staging
GROUP BY job_title
ORDER BY job_title


SELECT job_title , COUNT(*)
FROM   job_data_staging
GROUP BY job_title
HAVING COUNT(*) > 10
ORDER BY job_title

--- We start by Business Analyst and Senior Business Analyst
SELECT job_title 
FROM   job_data_staging
WHERE job_title  ILIKE '%SENIOR%' AND job_title  ILIKE '%ANALYST%'
ORDER BY job_title

SELECT job_title , REGEXP_REPLACE(job_title ,'.*','Business Analyst')
FROM   job_data_staging
WHERE   (job_title  ILIKE '%ANALYST%' AND job_title  ILIKE '%BUSINESS%') 
        AND job_title  NOT ILIKE '%Senior%'
ORDER BY job_title

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title ,'.*','Business Analyst')
WHERE   (job_title  ILIKE '%ANALYST%' AND job_title  ILIKE '%BUSINESS%') 
        AND job_title  NOT ILIKE '%Senior%'

SELECT job_title 
FROM   job_data_staging
WHERE   (job_title  ILIKE '%ANALYST%' AND job_title  ILIKE '%BUSINESS%') 
        AND job_title  NOT ILIKE '%Senior%'








SELECT job_title , REGEXP_REPLACE(job_title ,'.*','Senior Business Analyst')
FROM   job_data_staging
WHERE   (job_title  ILIKE '%ANALYST%' AND job_title  ILIKE '%BUSINESS%') 
        AND job_title  ILIKE '%Senior%'
ORDER BY job_title

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title ,'.*','Senior Business Analyst')
WHERE   (job_title  ILIKE '%ANALYST%' AND job_title  ILIKE '%BUSINESS%') 
        AND job_title  ILIKE '%Senior%'

SELECT job_title 
FROM   job_data_staging
WHERE   (job_title  ILIKE '%ANALYST%' AND job_title  ILIKE '%BUSINESS%') 
        AND job_title  ILIKE '%Senior%'


----Data analyst and Senior Data Analyst

SELECT DISTINCT job_title 
FROM   job_data_staging
WHERE job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%'
ORDER BY job_title ---- there was one row with 'Data Analyst/Engineer' we will update this one first


SELECT *  
FROM   job_data_staging
WHERE job_title  ILIKE '%DATA%/engineer%' --- after looking at the job_description and salary this seem to be more of a data engineer role

SELECT DISTINCT job_title, REPLACE(job_title,'Analyst/','')
FROM   job_data_staging
WHERE job_title  ILIKE '%DATA%/engineer%'

UPDATE job_data_staging
SET job_title = REPLACE(job_title,'Analyst/','')
WHERE job_title  ILIKE '%DATA%/engineer%'

SELECT *  
FROM   job_data_staging
WHERE index =  (SELECT index  
FROM   job_data_copy
WHERE job_title   ILIKE '%DATA%/engineer%'
)

SELECT DISTINCT job_title 
FROM   job_data_staging
WHERE job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%'
ORDER BY job_title ----- next we will update row 'Data Analyst II'

SELECT DISTINCT job_title , TRIM(' II' FROM job_title)
FROM   job_data_staging
WHERE job_title  ILIKE '%data%lyst II'

UPDATE job_data_staging
SET job_title = TRIM(' II' FROM job_title)
WHERE job_title  ILIKE '%data%lyst II'

SELECT *  
FROM   job_data_staging
WHERE index =  (SELECT index  
FROM   job_data_copy
WHERE job_title   ILIKE '%data%lyst II'
)

SELECT  job_title , REPLACE(job_title,'Data Analyst','Senior Data Analyst') 
FROM   job_data_staging
WHERE index =  (SELECT index  
FROM   job_data_copy
WHERE job_title   ILIKE '%data%lyst II'
)

UPDATE job_data_staging
SET job_title = REPLACE(job_title,'Data Analyst','Senior Data Analyst') 
WHERE index =  (SELECT index  
FROM   job_data_copy
WHERE job_title   ILIKE '%data%lyst II'
)

SELECT *  
FROM   job_data_staging
WHERE index =  (SELECT index  
FROM   job_data_copy
WHERE job_title   ILIKE '%data%lyst II'
)


----- Replace Senior role Data Analyst
SELECT DISTINCT job_title , REGEXP_REPLACE(job_title, '.*', 'Senior Data Analyst' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%') AND (job_title  ILIKE '%Sr%' OR job_title  ILIKE  '%senior%')

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Senior Data Analyst' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%') AND (job_title  ILIKE '%Sr%' OR job_title  ILIKE  '%senior%')

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%') AND (job_title  ILIKE '%Sr%' OR job_title  ILIKE  '%senior%'))

------ Replace Data Analyst

SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Data Analyst' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%') AND (job_title  NOT ILIKE  '%senior%')

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Data Analyst' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%') AND (job_title  NOT ILIKE  '%senior%')

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ANALYST%') AND (job_title  NOT ILIKE  '%senior%'))
ORDER BY index

---Software Engineer
SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Software Engineer' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%Software%' AND job_title  ILIKE '%Engineer%')

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Software Engineer' )
WHERE (job_title  ILIKE '%Software%' AND job_title  ILIKE '%Engineer%')

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%Software%' AND job_title  ILIKE '%Engineer%'))
ORDER BY index







--- Machine Learning Engineer
SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Machine Learning Engineer' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%Machine%' AND job_title  ILIKE '%Engineer%')

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Machine Learning Engineer' )
WHERE (job_title  ILIKE '%Machine%' AND job_title  ILIKE '%Engineer%')

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%Machine%' AND job_title  ILIKE '%Engineer%'))
ORDER BY index







--- Senior Data Scientist 
SELECT DISTINCT job_title , REGEXP_REPLACE(job_title, '.*', 'Senior Data Scientist' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') 
        AND (job_title  ILIKE '%SR%' OR 
            job_title  ILIKE '%Senior%' OR 
            job_title  ILIKE '%Experienced%' OR
            job_title  ILIKE '%intermediate%' OR
            job_title  ILIKE '%lead%' 
            ) 

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Senior Data Scientist' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') 
        AND (job_title  ILIKE '%SR%' OR 
            job_title  ILIKE '%Senior%' OR 
            job_title  ILIKE '%Experienced%' OR
            job_title  ILIKE '%intermediate%' OR
            job_title  ILIKE '%lead%' 
            ) 

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') 
        AND (job_title  ILIKE '%SR%' OR 
            job_title  ILIKE '%Senior%' OR 
            job_title  ILIKE '%Experienced%' OR
            job_title  ILIKE '%intermediate%' OR
            job_title  ILIKE '%lead%' 
            ) )
ORDER BY index

--- Data Scientist 
SELECT DISTINCT job_title, REGEXP_REPLACE(job_title, '.*', 'Data Scientist' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title NOT ILIKE '%Senior%' -- there was mid career still in the row we will update that first





SELECT DISTINCT job_title, REGEXP_REPLACE(job_title, '.*', 'Senior Data Scientist' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title ILIKE '%MID%' 

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Senior Data Scientist' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title ILIKE '%MID%' 

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title ILIKE '%MID%' )
ORDER BY index



SELECT DISTINCT job_title, REGEXP_REPLACE(job_title, '.*', 'Data Scientist' )
FROM   job_data_staging
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title NOT ILIKE '%Senior%' -- there was mid career still in the row we will update that first

UPDATE job_data_staging
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Data Scientist' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title NOT ILIKE '%Senior%' 

SELECT *  
FROM   job_data_staging
WHERE index IN  (SELECT index  
FROM   job_data_copy
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%SCIENTIST%') AND job_title NOT ILIKE '%Senior%' )
ORDER BY index


----- Check 
SELECT DISTINCT job_title 
FROM   job_data_staging
ORDER BY job_title


SELECT job_title , "median_yearly_salary_($)"
FROM   job_data_staging
ORDER BY job_title

SELECT *
FROM   job_data_copy



-------------------3.NULL AND MISSING VALUE -------------------
SELECT *
FROM job_data_staging
ORDER BY INDEX

DELETE FROM job_data_staging
WHERE JOB_TITLE IS NULL


SELECT  founded, headquarters
FROM job_data_staging
WHERE founded = -1 OR headquarters = '-1'

UPDATE job_data_staging
SET founded = NULL , headquarters= NULL
WHERE founded = -1 OR headquarters = '-1'


-------------------4.REMOVE UNNECCESSARY COLUMN ,outlier-------------------

ALTER TABLE job_data_staging
DROP COLUMN competitors

-- index 342 and 469 VP, Data Science seem to have an error everything is the same beside salary, we will remove index 469
DELETE FROM job_data_staging
WHERE index = 469

SELECT * FROM job_data_staging 
WHERE index = 469

-- 

SELECT * FROM job_data_copy

---- we will remove duplicate again as some job even if it has the same company, same location, industry, the difference in salary was too extreme
CREATE TABLE job_data_staging_2
(LIKE job_data_staging INCLUDING ALL )

ALTER TABLE job_data_staging_2
ADD COLUMN row_num TEXT

INSERT INTO job_data_staging_2
WITH duplicate_cte_2 AS(
SELECT 
    *,
    ROW_NUMBER()OVER(PARTITION BY 
                     job_title,
                     job_description,
                     company_name,industry 
                     ORDER BY "median_yearly_salary_($)" ASC
                     ) as row_num
 FROM 
    job_data_staging
)

SELECT 
    *
FROM
    duplicate_cte_2 
WHERE row_num = 1

SELECT 
    *
FROM
    job_data_staging_2
ORDER BY index

ALTER TABLE job_data_staging_2
DROP COLUMN row_num 

------- STANDARDIZE job_title
ALTER TABLE job_data_staging_2
RENAME COLUMN "median_yearly_salary_($)" to median_yearly_salary_USD 

SELECT DISTINCT job_title , median_yearly_salary_USD
FROM job_data_staging_2


SELECT   AVG(median_yearly_salary_USD)
FROM job_data_staging_2
WHERE job_title = 'Business Analyst' OR  job_title = 'Senior Business Analyst'
UNION
SELECT   *
FROM job_data_staging_2
WHERE job_title = 'Senior Business Analyst' ---- after we remove all duplicate Senior business  analyst was left only one row , we will group it into Business Analyst



SELECT   job_title, REGEXP_REPLACE(job_title, 'Senior Business Analyst', 'Business Analyst' )
FROM job_data_staging_2
WHERE job_title = 'Senior Business Analyst'

UPDATE job_data_staging_2
SET job_title= REGEXP_REPLACE(job_title, 'Senior Business Analyst', 'Business Analyst' )
WHERE job_title = 'Senior Business Analyst'


SELECT job_title , COUNT(*)
FROM job_data_staging_2
GROUP BY  job_title
HAVING COUNT(*)>=2

--- Data Engineer
SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Senior Data Engineer' )
FROM   job_data_staging_2
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ENGINEER%') AND (job_title  ILIKE '%SR%' OR job_title  ILIKE '%Senior%' OR job_title  ILIKE '%Principal%' ) 


UPDATE job_data_staging_2
SET job_title= REGEXP_REPLACE(job_title, '.*', 'Senior Data Engineer' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ENGINEER%') AND (job_title  ILIKE '%SR%' OR job_title  ILIKE '%Senior%' OR job_title  ILIKE '%Principal%' )



SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Data Engineer' )
FROM   job_data_staging_2
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ENGINEER%')  AND job_title  NOT ILIKE '%Senior%' 

UPDATE job_data_staging_2
SET job_title= REGEXP_REPLACE(job_title, '.*', 'Data Engineer' )
WHERE (job_title  ILIKE '%DATA%' AND job_title  ILIKE '%ENGINEER%') AND job_title  NOT ILIKE '%Senior%' 



-- ALL OTHER DISTINCT VALUE
SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Senior Data Analyst' )
FROM   job_data_staging_2
WHERE job_title  ILIKE '%Analytics%'

UPDATE job_data_staging_2
SET job_title= REGEXP_REPLACE(job_title, '.*', 'Senior Data Analyst' )
WHERE job_title  ILIKE '%Analytics%'

SELECT *
FROM job_data_staging_2
WHERE index IN ( SELECT 
                    index 
                FROM
                    job_data_staging
                WHERE job_title  ILIKE '%Analytics%'
               )


SELECT DISTINCT job_title , REGEXP_REPLACE(job_title, '.*', 'Senior Data Scientist' )
FROM   job_data_staging_2
WHERE (job_title NOT ILIKE 'Data Analyst' AND 
       job_title NOT ILIKE 'Data Engineer' AND 
       job_title NOT ILIKE 'Data Scientist' AND 
       job_title NOT ILIKE 'Business Analyst' AND
       job_title NOT ILIKE 'Senior Data Analyst' AND 
       job_title NOT ILIKE 'Senior Data Engineer' AND 
       job_title NOT ILIKE 'Senior Data Scientist' AND
       job_title NOT ILIKE 'Machine Learning Engineer' AND
       job_title NOT ILIKE 'Software Engineer'  ) 
       AND
       (job_title  ILIKE '%Principal%' OR
       job_title  ILIKE '%SR%' OR 
       job_title  ILIKE '%Senior%' OR 
       job_title  ILIKE '%Chief%' OR 
       job_title  ILIKE '%VP%' OR
       job_title  ILIKE '%Lead%' OR
       job_title  ILIKE '%Vice President%' OR
       job_title  ILIKE '%Experienced%' OR
       job_title  ILIKE '%Manager%' OR
       job_title  ILIKE '%Director%' 
        ) 

UPDATE job_data_staging_2
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Senior Data Scientist' )
WHERE (job_title NOT ILIKE 'Data Analyst' AND 
       job_title NOT ILIKE 'Data Engineer' AND 
       job_title NOT ILIKE 'Data Scientist' AND 
       job_title NOT ILIKE 'Business Analyst' AND
       job_title NOT ILIKE 'Senior Data Analyst' AND 
       job_title NOT ILIKE 'Senior Data Engineer' AND 
       job_title NOT ILIKE 'Senior Data Scientist' AND
       job_title NOT ILIKE 'Machine Learning Engineer' AND
       job_title NOT ILIKE 'Software Engineer'  ) 
       AND
       (job_title  ILIKE '%Principal%' OR
       job_title  ILIKE '%SR%' OR 
       job_title  ILIKE '%Senior%' OR 
       job_title  ILIKE '%Chief%' OR 
       job_title  ILIKE '%VP%' OR
       job_title  ILIKE '%Lead%' OR
       job_title  ILIKE '%Vice President%' OR
       job_title  ILIKE '%Experienced%' OR
       job_title  ILIKE '%Manager%' OR
       job_title  ILIKE '%Director%' 
        ) 


SELECT *
FROM job_data_staging_2
WHERE index IN ( SELECT 
                    index 
                FROM
                    job_data_staging
                WHERE (job_title NOT ILIKE 'Data Analyst' AND 
                job_title NOT ILIKE 'Data Engineer' AND 
                job_title NOT ILIKE 'Data Scientist' AND 
                job_title NOT ILIKE 'Business Analyst' AND
                job_title NOT ILIKE 'Senior Data Analyst' AND 
                job_title NOT ILIKE 'Senior Data Engineer' AND 
                job_title NOT ILIKE 'Senior Data Scientist' AND
                job_title NOT ILIKE 'Machine Learning Engineer' AND
                job_title NOT ILIKE 'Software Engineer'  ) 
                AND
                (job_title  ILIKE '%Principal%' OR
                job_title  ILIKE '%SR%' OR 
                 job_title  ILIKE '%Senior%' OR 
                job_title  ILIKE '%Chief%' OR 
                job_title  ILIKE '%VP%' OR
                job_title  ILIKE '%Lead%' OR
                job_title  ILIKE '%Vice President%' OR
                job_title  ILIKE '%Experienced%' OR
                job_title  ILIKE '%Manager%' OR
                job_title  ILIKE '%Director%' 
                ) 
                 ) 
               








SELECT DISTINCT job_title ,REGEXP_REPLACE(job_title, '.*', 'Data Scientist' )
FROM   job_data_staging_2
WHERE (job_title NOT ILIKE 'Data Analyst' AND 
       job_title NOT ILIKE 'Data Engineer' AND 
       job_title NOT ILIKE 'Data Scientist' AND 
       job_title NOT ILIKE 'Business Analyst' AND
       job_title NOT ILIKE 'Senior Data Analyst' AND 
       job_title NOT ILIKE 'Senior Data Engineer' AND 
       job_title NOT ILIKE 'Senior Data Scientist' AND
       job_title NOT ILIKE 'Machine Learning Engineer' AND
       job_title NOT ILIKE 'Software Engineer'  ) 

UPDATE job_data_staging_2
SET job_title = REGEXP_REPLACE(job_title, '.*', 'Data Scientist' )
WHERE (job_title NOT ILIKE 'Data Analyst' AND 
       job_title NOT ILIKE 'Data Engineer' AND 
       job_title NOT ILIKE 'Data Scientist' AND 
       job_title NOT ILIKE 'Business Analyst' AND
       job_title NOT ILIKE 'Senior Data Analyst' AND 
       job_title NOT ILIKE 'Senior Data Engineer' AND 
       job_title NOT ILIKE 'Senior Data Scientist' AND
       job_title NOT ILIKE 'Machine Learning Engineer' AND
       job_title NOT ILIKE 'Software Engineer'  ) 



SELECT DISTINCT *
FROM   job_data_staging_2


