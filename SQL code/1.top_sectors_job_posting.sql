--Question 1. Which sector has the most job available during COVID-19 (2020)?
  --- Offer insight into job availability in each sector for job seeker
 SELECT sector, COUNT(job_title) 
FROM job_data_staging_2
WHERE sector IS NOT NULL
GROUP BY sector
ORDER BY COUNT(job_title)  DESC

/*
Analysis of Job Postings by Sector in the U.S. (2020)
Insights:
Total Job Postings: 414

Dominance of Information Technology (IT):

-The IT sector accounts for 134 jobs (32.37%) job postings, this is to be expected, Data science role as heavily related to IT and technologies. 

-Business Services Comes Second 93 jobs (22.46%): Business services, which include consulting and professional services, show the growing need for data-driven decision-making in various businesses to handle COVID-19.

-Biotech & Pharmaceuticals 48 jobs (11.59%) :The high demand in biotech and pharma reflects the sector's prominence during the pandemic (e.g., vaccine development, supply chain management for medical supplies).

Aerospace & Defense 31 jobs (7.49%) :
Aerospace and defense also saw notable demand for data professionals, possibly tied to defense contracting and pandemic-related logistical needs.
Such as Operation Warp Speed (OWS) during COVID-19  aimed at accelerating the development, manufacturing, and distribution of COVID-19 vaccines, therapeutics, and diagnostics.



-Retail 6 jobs (1.45%) , Media 5  jobs (1.21%)  , and Travel & Tourism 2 jobs (0.48%)  saw significant declines in hiring during 2020 due to COVID-19 disruptions.
These sector was severely affected by COVID-19 lockdown adn that affect the number of job recruitment for these sectors.

-IT, Business Services, and Biotech were the dominant sectors for data-related roles in 2020, driven by digital transformation and pandemic-related needs.
Retail, Travel, and Media sectors were heavily impacted by COVID-19, showing reduced hiring.

*/




