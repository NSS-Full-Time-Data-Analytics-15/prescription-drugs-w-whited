--MVP
-- Q1
-- a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, total_claim_count
ORDER BY total_claim_count DESC
LIMIT 1;

select npi, sum(total_claim_count) as grand_total
from prescription
group by npi
order by grand_total desc;

--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
ORDER BY total_claim_count DESC
LIMIT 1;

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, sum(total_claim_count) as grand_total
FROM prescriber
INNER JOIN prescription
USING(npi)
group by nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY grand_total DESC
LIMIT 1;

--Q2
--a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS claims_by_specialty
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY claims_by_specialty DESC
LIMIT 1;

--b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count) AS claims_by_specialty
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING (drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY claims_by_specialty DESC
LIMIT 1;



--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?


SELECT distinct specialty_description, sum(total_claim_count) AS claims
FROM prescriber
FULL JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY claims desc
LIMIT 15;

SELECT specialty_description
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
HAVING SUM(TOTAL_CLAIM_COUNT) IS NULL

--**Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

SELECT specialty_description, 
ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END) * 100/ SUM (total_claim_count),2) AS percent_opioid
FROM prescription
INNER JOIN prescriber 
USING(npi)
INNER JOIN drug
USING(drug_name)
GROUP BY specialty_description
ORDER BY percent_opioid DESC NULLS LAST;

--Q3
--a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, MAX(total_drug_cost) AS cost
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY cost DESC
LIMIT 1;

SELECT generic_name, sum(total_drug_cost) AS cost
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY cost DESC
LIMIT 1;
--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, ROUND(total_drug_cost/ NULLIF(total_day_supply,0),2) AS cost_per_day
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name, total_day_supply, total_drug_cost
ORDER BY cost_per_day DESC
LIMIT 1;

select generic_name,
(sum(total_drug_cost)/sum(total_day_supply))::money as total_cost_per_day
from prescription inner join drug using (drug_name)
group by generic_name
order by total_cost_per_day desc
--Q4
-- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name, CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
					WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
					ELSE 'neither' END as drug_type
FROM drug;

--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
					WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
					ELSE 'neither' END as drug_type, SUM(total_drug_cost::money) amount_spent
FROM drug
INNER JOIN prescription
USING (drug_name)
GROUP BY drug_type
ORDER BY amount_spent desc;

select
sum(case when opioid_drug_flag = 'Y' then total_drug_cost end)::money as total_opioid_cost,
sum(case when antibiotic_drug_flag = 'Y' then total_drug_cost end)::money as total_antibiotic_cost,
sum(case when opioid_drug_flag = 'N' and antibiotic_drug_flag = 'N' then total_drug_cost end)::money as total_neither_cost
from drug inner join prescription using (drug_name);

--Q5
--a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT (distinct cbsa)
FROM cbsa
inner join fips_county
using(fipscounty)
WHERE state = 'TN';

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.


(SELECT cbsaname, SUM(population) AS total_pop, 'largest' AS cbsa_size
FROM population
INNER JOIN cbsa
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_pop DESC
LIMIT 1)
UNION
(SELECT cbsaname, SUM(population) AS total_pop, 'smallest' AS cbsa_size
FROM population
INNER JOIN cbsa
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_pop ASC
LIMIT 1)
ORDER BY TOTAL_POP DESC;

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

(SELECT county
FROM population
		INNER JOIN fips_county
		USING (fipscounty))
EXCEPT
(SELECT county
FROM cbsa
		INNER JOIN fips_county
		USING (fipscounty))
LIMIT 1;

SELECT county, population
from cbsa
FULL JOIN fips_county using (fipscounty)
inner join population using (fipscounty)
where cbsa is null
order by population desc
limit 1

--6
-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 3000;

--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count, CASE WHEN opioid_drug_flag = 'Y' THEN 'Y'
					ELSE 'N' END as opioid
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count > 3000;

SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count > 3000;

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count, CASE WHEN opioid_drug_flag = 'Y' THEN 'Y'
					ELSE 'N' END as opiod
FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count > 3000;

SELECT nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count > 3000
ORDER BY total_claim_count desc;

--7
--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber
CROSS JOIN DRUG
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
ORDER BY npi;

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).


SELECT prescriber.npi, drug.drug_name, SUM(prescription.total_claim_count) AS total_claim_count
FROM prescriber
CROSS JOIN drug 
INNER JOIN prescription
USING (npi)
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name;

SELECT npi, drug_name, coalesce(total_claim_count, 0) AS total_claim_count
FROM prescriber
CROSS JOIN drug 
left JOIN prescription
USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
;

--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug.drug_name, COALESCE(SUM(prescription.total_claim_count),0) AS total_claim_count
FROM prescriber
CROSS JOIN drug 
INNER JOIN prescription
USING (npi)
WHERE specialty_description = 'Pain Management' 
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name;

--BONUS
--1. How many npi numbers appear in the prescriber table but not in the prescription table?

SELECT COUNT(npi) prescriber_count
FROM prescriber
LEFT JOIN prescription
USING(npi)
WHERE prescription.npi IS NULL;

--2
--a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT generic_name, count(generic_name) AS generic_count
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY generic_count DESC;

--b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology
SELECT generic_name, count(generic_name) AS generic_count
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY generic_count DESC;

--c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
SELECT generic_name, count(generic_name) AS generic_count
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE specialty_description = 'Family Practice' OR specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY generic_count DESC;

--3
--a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
SELECT npi, total_claim_count, nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city ilike '%nashville%'
ORDER BY total_claim_count DESC
LIMIT 5;

--Now, report the same for Memphis.
SELECT npi, total_claim_count, nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city ILIKE '%memphis%'
ORDER BY total_claim_count DESC
LIMIT 5;

--Combine your results from a and b, along with the results for Knoxville and Chattanooga.
SELECT npi, total_claim_count, nppes_provider_city
FROM prescriber
INNER JOIN prescription
USING(npi)
WHERE nppes_provider_city ILIKE '%nashville%' 
OR nppes_provider_city ILIKE '%memphis%'
OR nppes_provider_city ILIKE '%knoxville%'
OR nppes_provider_city ILIKE '%chattanooga%'
ORDER BY total_claim_count DESC
LIMIT 5;

--4 Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

SELECT county, SUM(overdose_deaths) AS overdose_death_total
FROM overdose_deaths
INNER JOIN fips_county
ON CAST(fips_county.fipscounty AS INT) = overdose_deaths.fipscounty
WHERE overdose_deaths > (SELECT AVG(overdose_deaths) FROM overdose_deaths)
GROUP BY county
ORDER BY overdose_death_total DESC;
--5
--a. Write a query that finds the total population of Tennessee
SELECT SUM(population) AS tn_population
FROM population;

--b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.


SELECT county, population, ROUND(population * 100 /(SELECT SUM(population) FROM population),2) AS population_percent
FROM population
INNER JOIN fips_county
USING(fipscounty)
GROUP BY county, population
ORDER BY population_percent DESC;


