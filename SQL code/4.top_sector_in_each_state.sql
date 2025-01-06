/*Question 4.
  What are trend sector across each state in USA during COVID-19? 
  -- provide an insight demanding industry across state and how geographical effect job availability in each state.
*/


SELECT state ,sector ,COUNT(job_title), DENSE_RANK() OVER (PARTITION BY state ORDER BY COUNT(job_title) DESC) as ranking
FROM job_data_staging_2
WHERE sector IS NOT NULL AND size IS NOT NULL
GROUP BY state ,sector
ORDER BY state ,COUNT(job_title)  DESC


/*
Top Sectors by Demand:
1.Information Technology leads in nearly every state, highlighting its role in pandemic-driven transformation.
2.Biotech & Pharmaceuticals ranks high in states like Massachusetts, Maryland, and California, reflecting healthcare innovations.
3.Business Services is a versatile sector, contributing across diverse states.

Geographical Leaders:
1.California, Virginia, and New York lead in job postings due to their established ecosystems in tech, defense, and finance.
2.Maryland and Massachusetts showcase the impact of specialized industries like biotech and defense.

Impact of the Pandemic:
-IT, healthcare, and biotech grew in demand, while sectors like Retail, Travel, and Real Estate showed lower activity.

*/



-- Query for Map chart.
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
