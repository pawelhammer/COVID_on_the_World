
/* Count all of the workers from each seniority and list them by category of their job.
Create view for later visualization. */

create view levels_in_data as
select job_category, 
	count(case when experience_level = 'Entry-level' then 1 
		  else null end) 
		  as juniors,
	count(case when experience_level = 'Mid-level' then 1 
		  else null end) 
		  as mids,
	count(case when experience_level = 'Senior' then 1 
		  else null end)
		  as seniors,
	count(case when experience_level = 'Executive' then 1 
		  else null end)
		  as managers
from data_jobs
group by job_category

/* Show the percentages of workers of each experience level in top three most popular job categories.
Create view for later visualization. */

with sum_of_employees as(
	select job_category, 
	(juniors + mids + seniors + managers) as sum_of_workers
	from levels_in_data)
select e.job_category, e.sum_of_workers,
	round((l.juniors*100/e.sum_of_workers::numeric),2) as juniors_percentage,
	round((l.mids*100/e.sum_of_workers::numeric),2) as mids_percentage,
	round((l.seniors*100/e.sum_of_workers::numeric),2) as seniors_percentage,
	round((l.managers*100/e.sum_of_workers::numeric),2) as managers_percentage
from levels_in_data l
join sum_of_employees e
	on l.job_category = e.job_category
order by sum_of_workers desc
limit 3 

/* List workers who earn more and less than the average salary in their job. 
What is the difference between average earnings and their salary?
Create view for later visualization. */

create view above_and_below_average as
		with salary_rankings as(
		select worker_id, job_category, salary, 
		round(avg(salary_in_usd)over 
			(partition by job_category order by job_category),2) as average_salary
		from data_jobs
		) 
	select worker_id, job_category, average_salary,
		case when (salary > average_salary) then 'Above average' 
		when (salary < average_salary) then 'Below average' 
		else 'Average'
		end as earnings,
	abs(salary-average_salary) as difference
	from salary_rankings
	order by job_category

/* List all employees by continent they are living in 
and continent where company they are working for is located. */

with company_continent as
(
select worker_id, 
case when company_location in ('Indonesia', 'Singapore', 'Pakistan', 'Uzbekistan', 
	  'South Korea', 'Saudi Arabia', 'India', 'Iran', 'Vietnam', 'Malaysia', 'Israel',
	  'Hong Kong', 'Kuwait', 'Japan', 'Philippines', 'Iraq', 'Turkey', 'China', 
	  'Armenia', 'Qatar',' Pakistan', 'United Arab Emirates', 'Georgia', 'Thailand')
	  then 'Asia'
	  when company_location in ('Uganda', 'Egypt', 'Algeria', 'South Africa',
	  'Ghana', 'Kenya', 'Central African Republic', 'Mauritius', 'Nigeria', 
	  'Tunisia')
	  then 'Africa'
	  when company_location in ('Australia', 'New Zealand')
	  then 'Australia and Oceania'
	  when company_location in ('Italy', 'Luxembourg', 'Czech Republic', 'Sweden', 'Spain',
	  'United Kingdom', 'Ireland', 'Germany', 'Finland', 'Portugal', 'Malta', 'Gibraltar', 'Ukraine',
	  'Latvia', 'Slovenia', 'Greece', 'France', 'Estonia', 'Denmark', 'Bosnia and Herzegovina',
	  'Cyprus', 'Russia', 'Netherlands', 'Romania', 'Spain', 'Switzerland', 'Austria', 'Serbia', 
	  'Lithuania', 'Bulgaria', 'Spain', 'Croatia', 'Belgium', 'Moldova', 'Poland', 'Jersey', 'Andorra')
	  then 'Europe'
	  when company_location in ('Dominican Republic', 'American Samoa', 'Canada',
	  'Puerto Rico', 'United States', 'Mexico', 'Costa Rica', 'Bahamas')
	  then 'Northern America'
	  when company_location in ('Argentina', 'Chile', 'Colombia', 'Peru', 'Brazil', 
	  'Honduras', 'Bolivia')
	  then 'Southern America' end as company_continent
from data_jobs
),
worker_continent as
(
select worker_id, 
case when employee_residence in ('Indonesia', 'Singapore', 'Pakistan', 'Uzbekistan', 
	 'South Korea', 'Saudi Arabia', 'India', 'Iran', 'Vietnam', 'Malaysia', 'Israel',
	  'Hong Kong', 'Kuwait', 'Japan', 'Philippines', 'Iraq', 'Turkey', 'China', 
	  'Armenia', 'Qatar',' Pakistan', 'United Arab Emirates', 'Georgia', 'Thailand')
	  then 'Asia'
	  when employee_residence in ('Uganda', 'Egypt', 'Algeria', 'South Africa',
	  'Ghana', 'Kenya', 'Central African Republic', 'Mauritius', 'Nigeria', 
	  'Tunisia')
	  then 'Africa'
	  when employee_residence in ('Australia', 'New Zealand')
	  then 'Australia and Oceania'
	  when employee_residence in ('Italy', 'Luxembourg', 'Czech Republic', 'Sweden', 'Spain',
	  'United Kingdom', 'Ireland', 'Germany', 'Finland', 'Portugal', 'Malta', 'Gibraltar', 'Ukraine',
	  'Latvia', 'Slovenia', 'Greece', 'France', 'Estonia', 'Denmark', 'Bosnia and Herzegovina',
	  'Cyprus', 'Russia', 'Netherlands', 'Romania', 'Spain', 'Switzerland', 'Austria', 'Serbia', 
	  'Lithuania', 'Bulgaria', 'Spain', 'Croatia', 'Belgium', 'Moldova', 'Poland', 'Jersey', 'Andorra')
	  then 'Europe'
	  when employee_residence in ('Dominican Republic', 'American Samoa', 'Canada',
	  'Puerto Rico', 'United States', 'Mexico', 'Costa Rica', 'Bahamas')
	  then 'Northern America'
	  when employee_residence in ('Argentina', 'Chile', 'Colombia', 'Peru', 'Brazil', 
	  'Honduras', 'Bolivia')
	  then 'Southern America' end as residence_continent
from data_jobs
)
select w.worker_id, w.residence_continent, cc.company_continent
from worker_continent w
join company_continent cc
on w.worker_id = cc.worker_id

-- Are there people working from another continent than the one company is located on?

	select worker_id, residence_continent, company_continent
	from company_and_worker_continent
	where residence_continent <> company_continent

/* Analyse how many people work on which continent.
 List employees ranked by their minimal salary and grouped by job category.
 Include only people working full_time. 
 Create view for later visualization. */

create view min_max_salary as
	select cw.worker_id, cw.residence_continent, dj.job_category,
		min(salary) over w as min_salary,
		max(salary) over w as max_salary
	from company_and_worker_continent cw
	join data_jobs dj
		on cw.worker_id = dj.worker_id
	where dj.employment_type = 'Full-time'
		window w as (partition by dj.job_category order by dj.job_category)
