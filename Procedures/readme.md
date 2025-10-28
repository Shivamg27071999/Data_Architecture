Perfect ✅ Here’s your **GitHub-ready `README.md` file** — it explains everything in a structured, attractive way (with emojis, headings, and code formatting).
You can upload this file next to your `.sql` file in your GitHub repository.

---

## 📘 **README.md**

````markdown
# 💼 SQL Project: Employee & Student Management

### 📄 Description
This SQL project demonstrates advanced **data manipulation and analytical techniques** in SQL Server.  
It covers:
- Comparing employee salaries with departmental averages  
- Using **Window Functions** for analytical queries  
- Managing **student records** using a **Stored Procedure** with CRUD-like functionality

---

## 🧩 Project Structure

| File | Description |
|------|--------------|
| `Employee_And_Student_Procedures.sql` | Main SQL script containing all queries, window functions, and stored procedures |
| `README.md` | Documentation explaining the logic, process, and examples |

---

## 🧮 **1. Employee Analysis Section**

### 🔹 Objective
Find employees whose salary is **greater than the average salary of their department**.

### 🔸 Approach 1 — Using CTE (Common Table Expression)
```sql
with cte as (
    select dept_id, avg(salary) as avg_salary
    from employee
    group by dept_id
)
select e.*, e2.avg_salary
from employee e
inner join cte e2 on e.dept_id = e2.dept_id
where e.salary > e2.avg_salary;
````

🧠 *Explanation:*
The CTE first computes average salary per department.
Then we join it with the main employee table to filter employees who earn above their department’s average.

---

### 🔸 Approach 2 — Using Window Function (Better Approach)

```sql
select *
from (
    select *,
        avg(salary) over(partition by dept_id) as avg_dept_salary
    from employee
) e
where salary > avg_dept_salary;
```

🧠 *Explanation:*
`avg(salary) over(partition by dept_id)` dynamically calculates the department-wise average **for each row**, removing the need for joins.

---

## 🔢 **2. Window Function Frames**

### Example 1 — `PRECEDING`

```sql
select *,
    sum(salary) over(order by emp_id rows between 2 preceding and current row) as prec_salary
from employee;
```

🧠 *Explanation:*
This includes the current row and **2 rows above** for summation.

---

### Example 2 — `PRECEDING` + `FOLLOWING`

```sql
select *,
    sum(salary) over(order by emp_id rows between 1 preceding and 1 following) as prec_salary
from employee;
```

🧠 *Explanation:*
Includes one row above, current, and one below.
Useful for moving average or neighborhood-based calculations.

---

## 👨‍🎓 **3. Student Management System**

### Create Table

```sql
create table students (
    student_id int identity (1,1),
    email_id varchar(20),
    name varchar(20),
    country varchar(20)
);
```

---

### Create or Alter Procedure

```sql
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
        select * from students where email_id = @email_id;
    else 
    begin
        select @is_exists = COUNT(*) from students where email_id = @email_id;

        if @is_exists = 0
            insert into students values (@email_id, @name, @country);
        else
            update students set name=@name, country=@country where email_id=@email_id;
    end
end;
```

---

### Procedure Execution (Examples)

```sql
-- Insert or Update (POST)
exec sp_manage_students 'post', 'ankit@gmail.com', 'Ankit', 'India';
exec sp_manage_students 'post', 'nachiket@gmail.com', 'Nachiket', 'Australia';
exec sp_manage_students 'post', 'virat@gmail.com', 'VK', 'UK';

-- Retrieve (GET)
exec sp_manage_students 'get', 'ankit@gmail.com', null, null;

-- Retrieve unknown record
exec sp_manage_students 'get', 'unknown@gmail.com', null, null;
```

---

## 🧠 **Concepts Covered**

| Concept            | Description                                                   |
| ------------------ | ------------------------------------------------------------- |
| `CTE (WITH)`       | Temporary result set used for readability and modular queries |
| `Window Functions` | Aggregate values across related rows without grouping         |
| `ROWS BETWEEN`     | Defines a dynamic frame (range of rows) for calculations      |
| `Stored Procedure` | Reusable SQL logic with input parameters                      |
| `IF-ELSE Logic`    | Conditional control structure in SQL Server                   |

---

## 🧾 **Sample Outputs**

| emp_id | dept_id | salary | avg_dept_salary | Result      |
| ------ | ------- | ------ | --------------- | ----------- |
| 101    | 1       | 70000  | 65000           | ✅ Above Avg |
| 104    | 2       | 40000  | 35000           | ✅ Above Avg |
| 107    | 3       | 30000  | 32000           | ❌ Below Avg |

---

## 🚀 **How to Run**

1. Open SQL Server Management Studio (SSMS).
2. Create a database (e.g., `DemoDB`):

   ```sql
   create database DemoDB;
   use DemoDB;
   ```
3. Copy the contents of `Employee_And_Student_Procedures.sql` into a new query window.
4. Execute the script step by step.
5. Try modifying `@action_type` to `'get'` or `'post'` for different results.

---

## 🧑‍💻 **Author**

**Shivam**
🎓 MCA in Data Science
💡 Passionate about SQL, Analytics & Data Engineering


---

## ⭐ **Support**

If you found this helpful, don’t forget to:

* ⭐ Star this repository
* 🧠 Fork and practice
* 💬 Share your feedback

---

```

---

Would you like me to **add a short GitHub repo description and tags** (like the one that appears on top of your GitHub repo — e.g., “SQL | Window Functions | Stored Procedures”)?  
I can write that small 2–3-line summary too.
```
