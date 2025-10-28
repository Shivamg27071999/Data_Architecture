---------------------------------------------------------------------------------------------------------
-- 🔹 PART 1: Find Employees with Salary Greater than Department Average
---------------------------------------------------------------------------------------------------------

-- Step 1️⃣: Display the employee table (for reference)
select * from employee;


---------------------------------------------------------------------------------------------------------
-- 🧮 Normal Approach using CTE (Common Table Expression)
---------------------------------------------------------------------------------------------------------
-- Here, we first calculate the average salary per department
-- and then join it with the employee table to compare each employee's salary.

with cte as (
	select 
		dept_id, 
		avg(salary) as avg_salary 
	from employee 
	group by dept_id
)
select 
	e.*,
	e2.avg_salary
from employee e
inner join cte e2 
	on e.dept_id = e2.dept_id
where e.salary > e2.avg_salary;

---------------------------------------------------------------------------------------------------------
-- 🚀 Better Approach using Window Function
---------------------------------------------------------------------------------------------------------
-- The same logic but without using JOIN or GROUP BY.
-- Here, avg(salary) is calculated for each department directly using PARTITION BY.

select * 
from (
	select 
		*, 
		avg(salary) over(partition by dept_id) as avg_dept_salary 
	from employee
) e
where salary > avg_dept_salary;

-- ✅ Window functions make code shorter, cleaner, and often more efficient.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


-- 🔹 PART 2: Window Frame Examples
---------------------------------------------------------------------------------------------------------
-- Window frames control which rows are considered for aggregate calculations.

-- Example 1️⃣: Using PRECEDING
select 
	*, 
	sum(salary) over(
		order by emp_id 
		rows between 2 preceding and current row
	) as prec_salary
from employee;
-- 🔸 "2 preceding" means take current row + 2 rows above it for summation.
-- It does NOT skip rows, it counts number of rows.

---------------------------------------------------------------------------------------------------------
-- Example 2️⃣: Using PRECEDING and FOLLOWING
select 
	*, 
	sum(salary) over(
		order by emp_id 
		rows between 1 preceding and 1 following
	) as prec_salary
from employee;
-- 🔸 "1 preceding and 1 following" means one row above, current row, and one row below.
-- 🔸 "Unbounded preceding" = from the first row to the current row (cumulative sum).

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------


-- 🔹 PART 3: Create Table - STUDENTS
---------------------------------------------------------------------------------------------------------
-- This table stores student details.

create table students (
	student_id int identity (1,1),     -- Auto increment ID
	email_id varchar(20),              -- Email of the student (Unique)
	name varchar(20),                  -- Student name
	country varchar(20)                -- Country of the student
);

-- Example real-world use:
-- SignUp (Insert), Modify Profile (Update), Retrieve Profile (Select)
---------------------------------------------------------------------------------------------------------


-- 🔹 PART 4: Stored Procedure - sp_manage_students
---------------------------------------------------------------------------------------------------------
-- This procedure performs different actions based on the @action_type parameter:
--  @action_type = 'get'  → Retrieve student details
--  @action_type = 'post' → Insert or update student profile
---------------------------------------------------------------------------------------------------------

create or alter procedure sp_manage_students (
	@action_type varchar(4),
	@email_id varchar(20),
	@name varchar(20),
	@country varchar(20)
)
as
begin 
	declare @is_exists int;

	if @action_type = 'get'
	begin
		-- Retrieve student by email
		select * from students where email_id = @email_id;
	end
	else 
	begin
		-- Check if student exists
		select @is_exists = COUNT(*) from students where email_id = @email_id;

		if @is_exists = 0
		begin
			-- Insert new student record
			insert into students (email_id, name, country)
			values (@email_id, @name, @country);
			print 'New profile created successfully.';
		end
		else
		begin
			-- Update existing student profile
			update students 
			set name = @name, country = @country 
			where email_id = @email_id;
			print 'Your profile has been updated.';
		end
	end
end;
---------------------------------------------------------------------------------------------------------


-- 🔹 PART 5: Procedure Execution Examples
---------------------------------------------------------------------------------------------------------
-- Insert (SignUp)
exec sp_manage_students 'post', 'ankit@gmail.com' , 'Ankit' , 'India';
exec sp_manage_students 'post', 'nachiket@gmail.com' , 'Nachiket' , 'Australia';
exec sp_manage_students 'post', 'virat@gmail.com' , 'VK' , 'UK';

-- Retrieve (Get)
exec sp_manage_students 'get', 'ankit@gmail.com', null, null;

-- Retrieve non-existing email (shows no record)
exec sp_manage_students 'get', 'unknown@gmail.com', null, null;

---------------------------------------------------------------------------------------------------------
-- Verify all records
select * from students;
---------------------------------------------------------------------------------------------------------

