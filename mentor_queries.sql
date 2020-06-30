
-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- CREATE TABLE as Retirement_info
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

--Check the table
SELECT * FROM retirement_info;

--Delete the table if required
DROP TABLE retirement_info;

--Joining retirement_info and dept_emp tables
SELECT retirement_info.emp_no,
	retirement_info.first_name,
	retirement_info.last_name,
	dept_emp.to_date
FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no;

--Joining retirement_info and dept_emp tables using alias
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

--Joining departments and dept_manager tables
SELECT departments.dept_name,
	dept_manager.emp_no,
	dept_manager.from_date,
	dept_manager.to_date
FROM departments
INNER JOIN dept_manager
ON departments.dept_no = dept_manager.dept_no;
	
--Joining departments and dept_manager tables using alias
SELECT d.dept_name,
	dm.emp_no,
	dm.from_date,
	dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

--Joining retirement_info and dept_emp tables using alias and create new table
--Table containing only the current employees who are eligible for retirement 
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
INTO current_emp	
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

SELECT * FROM current_emp;

--Employees count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO retirement_count
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

SELECT * FROM retirement_count;

SELECT * FROM salaries
ORDER BY to_date DESC;

-- CREATE TABLE as emp_info
SELECT emp_no,
	first_name,
	last_name,
	gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- CREATE TABLE as emp_info
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	e.gender,
	s.salary,
	de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
	AND (de.to_date = '9999-01-01');
	
SELECT * FROM emp_info;


--List of managers per department
SELECT dm.dept_no,
	d.dept_name,
	dm.emp_no,
	ce.last_name,
	ce.first_name,
	dm.from_date,
	dm.to_date
INTO manager_info
FROM dept_manager as dm
INNER JOIN departments as d
ON (dm.dept_no = d.dept_no)
INNER JOIN current_emp as ce
ON (dm.emp_no = ce.emp_no);

SELECT * FROM manager_info;

--List of retiring employees per department
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_emp as de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no);

SELECT * FROM dept_info;

--LIST of retiring employees in sales department
SELECT 	ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name
INTO retirees_sales
FROM retirement_info as ri
INNER JOIN dept_emp as de
ON (ri.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name = ('Sales');

SELECT * FROM retirees_sales;

--LIST of retiring employees in sales and development departments
SELECT 	ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name
INTO retirees_sales_devpmt
FROM retirement_info as ri
INNER JOIN dept_emp as de
ON (ri.emp_no = de.emp_no)
INNER JOIN departments as d
ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales','Development');

SELECT * FROM retirees_sales_devpmt;



--Module 7 challenge work starts from here.
--LIST of (titles) retiring employees
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	ti.title,
	ti.from_date,
	s.salary	
INTO titles_retirees
FROM current_emp as ce
INNER JOIN titles as ti
ON (ce.emp_no = ti.emp_no)
INNER JOIN salaries as s
ON (ce.emp_no = s.emp_no);

SELECT * FROM titles_retirees;

--List of Only the Most Recent Titles
--list of retirees with their titles in decending order as per from_date column
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY from_date DESC) AS r_num
INTO titles_order
FROM titles_retirees
ORDER BY emp_no ASC;

SELECT * FROM titles_order;


--List of retirees with their current titles
SELECT  
	emp_no, first_name, last_name, title, from_date, salary
INTO titles_current
FROM titles_order
WHERE r_num=1;

SELECT * FROM titles_current;


--List of the title count 
SELECT emp_no, first_name, last_name, title, from_date, salary,
	COUNT(emp_no) OVER (PARTITION BY title) AS t_count
INTO count_titles
FROM titles_current
ORDER BY emp_no ASC;

SELECT * FROM count_titles;

--List of the frequency count of employee titles 
SELECT DISTINCT title,t_count
INTO titles_count
FROM count_titles;

SELECT * FROM titles_count;

--List of employees who are ready for Mentorship
SELECT
	e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	ti.from_date,
	de.to_date
INTO mentor_table
From employees as e INNER JOIN titles as ti ON (e.emp_no = ti.emp_no)
INNER JOIN dept_emp as de ON (e.emp_no = de.emp_no)
WHERE e.birth_date BETWEEN '1965-01-01' AND '1965-12-31'
AND de.to_date = '9999-01-01';

SELECT * FROM mentor_table;

--List of mentors with their current titles
with my_table as (
SELECT *, row_number() OVER (Partition By first_name, last_name Order by from_date desc) as r_num
FROM mentor_table) 
Select * 
INTO mentor_table_uniquified
From my_table where r_num = 1

Select emp_no, first_name, last_name, title,from_date,to_date
INTO mentors_current
	from mentor_table_uniquified
ORDER BY emp_no ASC;

SELECT * FROM mentors_current;

	












