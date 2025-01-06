/* 
Question 2.
    Which states has the most online job posting during the start of COVID-19 (2020)?
    - providing insight for job seeker, to see which states has the most job opputunity even during COVID-19
*/
 SELECT state , COUNT(job_title) 
FROM job_data_staging_2
GROUP BY state
ORDER BY COUNT(job_title)  DESC


/*
Insights:
Total
California (CA) leads significantly:
California, with 116 job postings (29.74%) , is far ahead of other states, accounting for nearly 30% of the total jobs listed.
This is likely due to the presence of Silicon Valley (Meta , Google , Mircrosoft etc.)and its tech ecosystem, which drives demand for data-related roles.

Virginia (VA) is second:
Virginia has 68 job postings  (17.44%),  home to government contractors, defense, and IT-related industries including Boeing ,Amazon Web Services (AWS)

New York (NY) and Massachusetts (MA) tied for third:
Both states have 40 job postings   (10.26%) each:
NY: A financial hub with a strong demand for data professionals in finance and banking.
MA: Boston's tech, healthcare, and education industries are key drivers these including company like Moderna , Takeda etc.
Maryland (MD), Illinois (IL), and Washington D.C. follow:
Maryland 27 job postings (6.92%), Illinois 24 job postings  (6.15%) , and Washington D.C. 18  job postings (4.62%) also show significant job opportunities, reflecting their roles in healthcare, government, and urban tech hubs.

