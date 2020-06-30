# Pewlett-Hackard-Analysis

## Project Overview
Database analysis for the employees eligible for the retirement has been carried out. The retirement criterion was that the birth date of the 
employee should be between 1952 and 1955. And also the employee should be hired between 1985 and 1988.

## Software
SQL, PostgreSQL, pgAdmin 

## Summary
### Number of individuals retiring 
There are 33118 current employees which are retiring  as per the above criterion.	
	

### Number of individuals being hired 
The number of individuals being hired should be ideally equal to the number of retirees (i.e.33118). But there should also be 
some criterion for hiring as well.

### Number of individuals available for mentorship role 
There are 1549 employees who are eligible for mentorship role.The mentorship criterion was that the employee should be born 
in year 1965. 

### Recommendation for further analysis on this data set	
There should be some criterion for hiring individuals as well. Because with the change of time and the technology enhancement 
or automation the company requirement changes. Also the current salary should be updated in the database after the employees's 
promotion. 
 
	

## Entity Relationship Diagram:

![alt text](https://github.com/ArchanaRohilla/Pewlett-Hackard-Analysis/blob/master/Images/EmployeeDB.png)

	

## Code for the queries

### List of (titles) retiring employees

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

	* Refer to titles_retirees.csv in Data folder.
	SELECT * FROM titles_retirees;

### List of Only the Most Recent Titles

### List of retirees with their titles in decending order as per from_date column

	SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY from_date DESC) AS r_num
	INTO titles_order
	FROM titles_retirees
	ORDER BY emp_no ASC;

	SELECT * FROM titles_order;

	--Partition the data to show only most recent title per employee
	--List of retirees with their current titles
	SELECT  
		emp_no, first_name, last_name, title, from_date, salary
	INTO titles_current
	FROM titles_order
	WHERE r_num=1;

	--Refer to titles_current.csv in Data folder.
	SELECT * FROM titles_current;

### List of the title count

	SELECT emp_no, first_name, last_name, title, from_date, salary,
		COUNT(emp_no) OVER (PARTITION BY title) AS t_count
	INTO count_titles
	FROM titles_current
	ORDER BY emp_no ASC;

	SELECT * FROM count_titles;

	--List of the frequency count of employee titles. 
	SELECT DISTINCT title,t_count
	INTO titles_count
	FROM count_titles;

	--Refer to titles_count.csv in Data folder.
	SELECT * FROM titles_count;

### List of employees who are ready for Mentorship

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

### List of mentors with their current titles
![mentors_current](https://github.com/ArchanaRohilla/Pewlett-Hackard-Analysis/blob/master/Images/mentor_current.png)


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
	
	--Refer to mentors_current.csv in Data folder.
	SELECT * FROM mentors_current;








