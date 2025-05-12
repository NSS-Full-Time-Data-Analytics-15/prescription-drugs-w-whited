SELECT COUNT(drug_name)
FROM drug;

SELECT COUNT(DISTINCT drug_name)
FROM drug;


--1. 
--A.
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims desc;

--B.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY total_claims desc;


--2.
--A.
SELECT specialty_description, sum(total_claim_count) as total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
GROUP BY specialty_description
order by total_claims desc;

--B.
SELECT specialty_description, sum(total_claim_count) as total_claims
FROM prescription
INNER JOIN prescriber
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claims DESC;

--C.
SELECT specialty_description
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
HAVING SUM(total_claim_count) IS NULL;

--D.

--3.
--A.
SELECT generic_name, sum(total_drug_cost)::money AS total_cost
FROM prescription
INNER JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC;

--B.
SELECT generic_name, (SUM(total_drug_cost) / SUM(total_day_supply))::money as day_cost
FROM prescription
INNER JOIN drug
USING(drug_name)
GROUP BY generic_name
ORDER BY day_cost DESC;

--4.
--A.
SELECT drug_name,
CASE
	WHEN opioid_drug_flag = 'Y' then 'opioid'
	WHEN antibiotic_drug_flag = 'Y' then 'antibiotic' else 'neither' 
END AS drug_type
FROM drug;

--B.
SELECT
CASE
	WHEN opioid_drug_flag = 'Y' then 'opioid'
	WHEN antibiotic_drug_flag = 'Y' then 'antibiotic' else 'neither' 
END AS drug_type, sum(total_drug_cost)::MONEY AS total_cost 
FROM drug
INNER JOIN prescription
USING (drug_name)
WHERE opioid_drug_flag = 'Y' OR antibiotic_drug_flag = 'Y'
GROUP BY drug_type 
ORDER BY total_cost DESC;

--5.
--A.
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname like '%TN';

--B.
SELECT cbsaname, SUM(population) as total_population
FROM cbsa
INNER JOIN population 
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC;

SELECT cbsaname, SUM(population) as total_population
FROM cbsa
INNER JOIN population 
USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population ASC;

--C.






