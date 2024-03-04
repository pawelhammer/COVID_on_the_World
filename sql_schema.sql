DROP TABLE IF EXISTS public.data_jobs;
CREATE TABLE IF NOT EXISTS public.data_jobs
(
    worker_id integer NOT NULL PRIMARY KEY,
	work_year integer NOT NULL,
    job_title character varying(50) NOT NULL,
    job_category character varying(50) NOT NULL,
    salary_currency character varying(3) NOT NULL,
    salary integer NOT NULL,
    salary_in_usd integer NOT NULL,
    employee_residence character varying(30) NOT NULL,
    experience_level character varying(20) NOT NULL,
    employment_type character varying(20) NOT NULL,
    work_setting character varying(20) NOT NULL,
    company_location character varying(30) NOT NULL,
    company_size character varying(1) COLLATE NOT NULL
)

COPY data_jobs
FROM
'C:\Users\templ\Desktop\Projekt SQL\Data_jobs_case_study\data_jobs.csv'
DELIMITER ',' CSV HEADER;