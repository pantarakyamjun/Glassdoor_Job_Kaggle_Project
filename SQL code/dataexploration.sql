SELECT * FROM job_data_staging_2



SELECT job_title, COUNT(*)
FROM job_data_staging_2
GROUP BY job_title
ORDER BY COUNT(*) DESC

SELECT job_title, AVG(median_yearly_salary_USD)
FROM job_data_staging_2
GROUP BY job_title
ORDER BY job_title --- 1.result show data scientist got paid more than senior, and that is should not be  possible 

SELECT sector,job_title, ROUND(AVG(median_yearly_salary_USD),0) as median_salary_
FROM job_data_staging_2
WHERE job_title = 'Data Analyst'
GROUP BY sector,job_title
ORDER BY median_salary_ DESC
LIMIT 5

SELECT sector,job_title, ROUND(AVG(median_yearly_salary_USD),0) as median_salary_
FROM job_data_staging_2
WHERE job_title = 'Data Engineer'
GROUP BY sector,job_title
ORDER BY median_salary_ DESC
LIMIT 5


SELECT sector,job_title, ROUND(AVG(median_yearly_salary_USD),0) as median_salary_
FROM job_data_staging_2
WHERE job_title = 'Data Scientist'
GROUP BY sector,job_title
ORDER BY median_salary_ DESC
LIMIT 5
/*the data that was shown was too counterintuitive, the data area that pay the most should be Finance, health , technology*
we will look into this more whether this come from data inaccuracy or not*/



SELECT state ,job_title, ROUND(AVG(median_yearly_salary_USD),0) as median_salary_
FROM job_data_staging_2
WHERE job_title = 'Data Scientist'
GROUP BY state,job_title
ORDER BY median_salary_ DESC
LIMIT 5
/*States with the Highest cost of living in the USA  NY (New York) , MA(Massachesetts), CA(California) , NJ(New jersey)
 There was none of the above included, median_salary might not be accurate as we want it to be)*/





-- Which states has the most online job posting during the start of COVID-19 (2020)?
 SELECT state , COUNT(job_title) 
FROM job_data_staging_2
GROUP BY state
ORDER BY COUNT(job_title)  DESC
LIMIT 5


-- Which sector has the most job available during COVID-19 (2020)?
 SELECT sector, COUNT(job_title) 
FROM job_data_staging_2
WHERE sector IS NOT NULL
GROUP BY sector
ORDER BY COUNT(job_title)  DESC
LIMIT 5







-- Which jobs has the most job posting during Covid-19?

SELECT job_title, COUNT(*)
FROM job_data_staging_2
GROUP BY job_title
ORDER BY COUNT(*) DESC




-- How does company size effect amount of job posting?
 SELECT size, COUNT(job_title) 
FROM job_data_staging_2
GROUP BY size
ORDER BY COUNT(job_title)  DESC




--Propotional company size FOR jobposting for each sector : 
 SELECT sector,size ,COUNT(job_title) AS count,  DENSE_RANK() OVER (PARTITION BY sector ORDER BY COUNT(job_title) DESC) as ranking
FROM job_data_staging_2
WHERE sector IS NOT NULL AND size IS NOT NULL
GROUP BY sector,size
ORDER BY sector ,COUNT(job_title)  DESC



-- State, Sector , jobposting
WITH state_sector_cte AS(
 SELECT state ,sector ,COUNT(job_title), DENSE_RANK() OVER (PARTITION BY state ORDER BY COUNT(job_title) DESC) as ranking
FROM job_data_staging_2
WHERE sector IS NOT NULL AND size IS NOT NULL
GROUP BY state ,sector
ORDER BY state ,COUNT(job_title)  DESC
)
SELECT *
FROM state_sector_cte 
WHERE ranking =1
ORDER BY count DESC

