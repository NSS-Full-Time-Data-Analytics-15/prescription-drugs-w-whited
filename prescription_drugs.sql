--Q1.
--A.

SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC
LIMIT 1;

--B.

SELECT nppes_provider_first_name AS first_name, nppes_provider_last_org_name AS last_name, specialty_description, sum(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING (NPI)
GROUP BY first_name, last_name, specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--2.
--A.

SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
GROUP BY specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--B.

SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claims DESC
LIMIT 1;

--C.

SELECT specialty_description
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
HAVING SUM(total_claim_count) IS NULL;

--D.

SELECT specialty_description, ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END) / SUM(total_claim_count) *100,2) AS pct_opioid
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
GROUP BY specialty_description
ORDER BY pct_opioid DESC NULLS LAST;

--3.
--A.

SELECT generic_name, SUM(total_drug_cost)::MONEY AS total_cost
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

--B.

SELECT generic_name, (SUM(total_drug_cost)/ SUM(total_day_supply))::MONEY AS total_cost
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

--4.
--A. 
SELECT drug_name, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--B. 
SELECT  
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type, SUM(total_drug_cost)::MONEY AS total_cost
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;

--5.
--A.

SELECT COUNT(DISTINCT cbsaname)
FROM cbsa
INNER JOIN fips_county
USING(fipscounty)
WHERE state = 'TN';

--B.

(SELECT cbsaname, SUM(population) AS total_population, 'largest' AS cbsa_size
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC
LIMIT 1)
UNION
(SELECT cbsaname, SUM(population) AS total_population, 'smallest' AS cbsa_size
FROM cbsa
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population ASC
LIMIT 1)
ORDER BY total_population DESC;

--C.
SELECT *
FROM cbsa
FULL JOIN fips_county
USING(fipscounty)
INNER JOIN population
USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC
LIMIT 1;

--6.
--A.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--B.

SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug
USING(drug_name)
WHERE total_claim_count >= 3000;

--C.
SELECT drug_name, total_claim_count, opioid_drug_flag, CONCAT(nppes_provider_first_name, ' ', nppes_provider_last_org_name) AS provider
FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count >= 3000;

--7.
--A.

SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
ORDER BY npi;

--B.
SELECT npi, drug_name, total_claim_count AS total_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
ORDER BY total_claims DESC NULLS LAST;

--C.

SELECT npi, drug_name, COALESCE(total_claim_count, 0) AS total_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND opioid_drug_flag = 'Y'
ORDER BY total_claims DESC NULLS LAST;



