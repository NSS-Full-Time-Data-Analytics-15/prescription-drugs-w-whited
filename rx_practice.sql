--1
--a. 
select npi, sum(total_claim_count)
from prescriber
inner join prescription
using (npi)
group by npi
order by sum(total_claim_count) desc
limit 1;

--b 
select nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, sum(total_claim_count)
from prescriber
inner join prescription
using (npi)
group by nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
order by sum(total_claim_count) desc
limit 1;

--2
--a
select specialty_description, sum(total_claim_count)
from prescriber
inner join prescription
using(npi)
group by specialty_description
order by sum(total_claim_count) desc

--b
select specialty_description, sum(total_claim_count)
from prescriber
inner join prescription
using(npi)
inner join drug
using(drug_name)
where opioid_drug_flag = 'Y'
group by specialty_description
order by sum(total_claim_count) desc
limit 1

--c 
select specialty_description
from prescriber 
left join prescription
using(npi)
group by specialty_description
having sum(total_claim_count) is null

--d
select specialty_description,
	round(sum(case when opioid_drug_flag = 'Y' then total_claim_count end)/sum(total_claim_count) * 100,2) as pct_opioid
from prescription
inner join prescriber
using(npi)
inner join drug
using(drug_name)
Group by specialty_description
order by pct_opioid desc
nulls last;
--3
--a 
select generic_name, sum(total_drug_cost)::money as total_cost
from prescription
inner join drug using(drug_name)
group by generic_name
order by sum(total_drug_cost) desc
limit 1;

--b
select generic_name, (sum(total_drug_cost) / sum(total_day_supply))::money as cost_per_day
from prescription
inner join drug using(drug_name)
group by generic_name
order by cost_per_day desc

--4
--a
select drug_name,
case when opioid_drug_flag = 'Y' then 'opioid'
		when antibiotic_drug_flag = 'Y' then 'antibiotioc'
		else 'neither' end as drug_type
from drug

--b
select
		(sum(case when opioid_drug_flag = 'Y' then total_drug_cost end))::money as total_opioid_cost,
		(sum(case when antibiotic_drug_flag = 'Y' then total_drug_cost end))::money as total_antibiotic_cost,
		(sum(case when (opioid_drug_flag = 'N' and antibiotic_drug_flag = 'N') Then total_drug_cost end))::money as total_neither_cost
from drug
inner join prescription using(drug_name)

--5
--a
select count(distinct cbsaname)
from cbsa
inner join fips_county
using(fipscounty)
where state ='TN'

--b
(select cbsaname, sum(population) as total_population, 'largest' as cbsa_size
from cbsa
inner join population
using(fipscounty)
group by cbsaname
order by total_population desc
limit 1)
union
(select cbsaname, sum(population) as total_population, 'smallest' as cbsa_size
from cbsa
inner join population
using(fipscounty)
group by cbsaname
order by total_population asc
limit 1)
order by total_population desc

--c
select county, population as total_pop
from population
inner join fips_county
using(fipscounty)
left join cbsa
using(fipscounty)
where cbsa is null
order by total_pop desc
limit 1

--6
--a
select drug_name, total_claim_count
from prescription
where total_claim_count > 3000;

--b
select drug_name, total_claim_count,
		case when opioid_drug_flag = 'Y' then 'Y' else 'N' end as Opioid
from prescription
inner join drug
using(drug_name)
where total_claim_count > 3000

--c
select concat(nppes_provider_first_name,' ', nppes_provider_last_org_name) as provider_name, drug_name, total_claim_count
from prescription
inner join drug
using(drug_name)
inner join prescriber
using(npi)
where total_claim_count > 3000

--7
--a
select npi, drug_name
from prescriber
cross join drug
where specialty_description = 'Pain Management'
and nppes_provider_city ilike 'nashville'
and opioid_drug_flag = 'Y'

--b
select prescriber.npi, drug_name, total_claim_count
	from prescriber
		cross join drug
		left join prescription
		using(npi,drug_name)
		where prescriber.specialty_description = 'Pain Management'
		and nppes_provider_city ilike 'nashville'
		and opioid_drug_flag = 'Y'
		order by total_claim_count desc
	
--c
select prescriber.npi, drug_name, coalesce(total_claim_count, 0) as total_claims
	from prescriber
		cross join drug
		left join prescription
		using(npi,drug_name)
		where prescriber.specialty_description = 'Pain Management'
		and nppes_provider_city ilike 'nashville'
		and opioid_drug_flag = 'Y'
		order by total_claims desc


--1
--a
select npi, sum(total_claim_count) as total_claims
from prescription
group by npi
order by total_claims desc
limit 1

--b
select nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, sum(total_claim_count) as total_claims
from prescription
inner join prescriber
using(npi)
group by nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
order by total_claims desc
limit 1

--2
--a
select specialty_description, sum(total_claim_count) as total_claim
from prescription
inner join prescriber
using(npi)
group by specialty_description
order by total_claim desc
limit 1;

--b
select specialty_description, sum(total_claim_count) as total_claims
from prescriber
inner join prescription
using(npi)
inner join drug
using(drug_name)
where opioid_drug_flag = 'Y'
group by specialty_description
order by total_claims desc
limit 1

--c
select specialty_description
from prescriber
left join prescription
using(npi)
where total_claim_count is null
group by specialty_description

--d
select specialty_description,
round(sum(case when opioid_drug_flag = 'Y' then total_claim_count end)/ sum(total_claim_count) *100,2) as pct_opioid
from prescriber
inner join prescription
using(npi)
inner join drug
using(drug_name)
group by specialty_description
order by pct_opioid desc
nulls last

--3
--a 
select generic_name, sum(total_drug_cost)::money as cost
from prescription
inner join drug
using(drug_name)
group by generic_name
order by cost desc
limit 1;

--b
select generic_name, (sum(total_drug_cost)/sum(total_day_supply))::money as cost_per_day
from prescription
inner join drug
using(drug_name)
group by generic_name
order by cost_per_day desc
limit 1;

--4
--a 
select drug_name,
		case when opioid_drug_flag = 'Y' then 'opioid'
		     when antibiotic_drug_flag = 'Y' then 'antibiotic'
			 else 'neither' end as drug_type
from drug;

--b
select
			(sum(case when opioid_drug_flag = 'Y' then total_drug_cost end))::money as opioid_total,
		    (sum(case when antibiotic_drug_flag = 'Y' then total_drug_cost end))::money as antibiotic_total,
			(sum(case when opioid_drug_flag = 'N' and antibiotic_drug_flag = 'N' then total_drug_cost end))::money neither_total
from drug
inner join prescription
using(drug_name);

--5
--a
select count(distinct cbsa)
from cbsa
inner join fips_county
using(fipscounty)
where state = 'TN'

--b
(select cbsaname, sum(population) as total_pop, 'largest' as population
from cbsa
inner join population
using(fipscounty)
group by cbsaname
order by total_pop desc
limit 1)
union
(select cbsaname, sum(population) as total_pop, 'smallest' as population
from cbsa
inner join population
using(fipscounty)
group by cbsaname
order by total_pop
limit 1)
order by total_pop desc

--c
select county, sum(population) as total_pop
from population
left join cbsa
using(fipscounty)
inner join fips_county
using(fipscounty)
where cbsa is null
group by county
order by total_pop desc
limit 1

--6
--a
select drug_name, total_claim_count
from prescription
where total_claim_count > 3000;

--b
select drug_name, total_claim_count, case when opioid_drug_flag = 'Y' then 'Y' else 'N' end as opioid
from prescription
inner join drug
using(drug_name)
where total_claim_count > 3000;

--c
select concat(nppes_provider_first_name,' ', nppes_provider_last_org_name),drug_name, total_claim_count, case when opioid_drug_flag = 'Y' then 'Y' else 'N' end as opioid
from prescription
inner join drug
using(drug_name)
inner join prescriber
using(npi)
where total_claim_count > 3000;

--7
--a
select npi, drug_name
from prescriber
cross join drug
where specialty_description = 'Pain Management'
and nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'

--b
select prescriber.npi, drug_name, total_claim_count
from prescriber
cross join drug
left join prescription
using(drug_name, npi)
where specialty_description = 'Pain Management'
and nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'


--c
select prescriber.npi, drug_name, coalesce(total_claim_count,0) as claim_count
from prescriber
cross join drug
left join prescription
using(drug_name, npi)
where specialty_description = 'Pain Management'
and nppes_provider_city = 'NASHVILLE'
and opioid_drug_flag = 'Y'
