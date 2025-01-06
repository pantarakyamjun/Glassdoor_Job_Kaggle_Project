/*Question 3.
  What are proportion of company size for each sector? 
  -- provide an insight into the compostion of company business size for each sector
*/
 SELECT sector,size ,COUNT(job_title) AS count,  DENSE_RANK() OVER (PARTITION BY sector ORDER BY COUNT(job_title) DESC) as ranking
FROM job_data_staging_2
WHERE sector IS NOT NULL AND size IS NOT NULL
GROUP BY sector,size
ORDER BY sector ,COUNT(job_title)  DESC


/*
Summary:
Sector Dominance Across Sizes
Information Technology (IT):

Dominates across all company sizes, with 64 (Medium), 31 (Large), 20 (Small), and 19 (Enterprise) postings.
IT's resilience and growth are driven by the pandemic's digital transformation needs.
Business Services:

Second most prominent, with 41 (Medium), 22 (Large), and 17 (Small) postings.
Reflects companies’ needs for data-driven decision-making and consulting during COVID-19 disruptions.

Biotech & Pharmaceuticals:
A high number of postings, particularly 17 (Enterprise), 16 (Large), and 13 (Medium), showcase the sector’s importance in vaccine development, supply chain optimization, and healthcare solutions.
Government, Health Care, and Finance:

Steady demand across company sizes reflects their critical roles during the pandemic.
Government and Finance primarily hired at Enterprise and Large levels, while Health Care hiring extended to smaller companies.
Lagging Sectors:

Sectors like Retail, Travel & Tourism, Agriculture, and Non-Profit show minimal job postings, highlighting COVID-19's significant impact on these industries.
*/