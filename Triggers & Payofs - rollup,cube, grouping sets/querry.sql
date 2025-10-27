/* =====================================================================================
   Project: SQL Triggers and Grouping Operations
   Description: Demonstration of SQL Triggers (INSERT, DELETE, UPDATE)
                and Grouping Techniques using ROLLUP and CUBE.
   Author: Shivam
   Date: October 2025
===================================================================================== */


/* -------------------------------------------------------------------------------------
   SECTION 1: EMPLOYEE TABLE AND AUDIT LOGGING SYSTEM
   ------------------------------------------------------------------------------------- */

/* 
   STEP 1: Create Employee Table
   This table stores basic employee information such as ID, name, email, and salary.
*/
CREATE TABLE Aud_employee (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    email_id VARCHAR(50),
    salary INT
);

/* 
   STEP 2: Insert Sample Data into Employee Table
   We’ll use a few sample employee records for trigger demonstration.
*/
INSERT INTO Aud_employee (employee_id, employee_name, email_id, salary) VALUES
(101, 'Liam Alton', 'li.al@abc.com', 10000),
(102, 'Josh Day', 'jo.da@abc.com', 20000),
(103, 'Sean Mann', 'se.ma@abc.com', 30000),
(104, 'Evan Blake', 'ev.bl@abc.com', 40000),
(105, 'Toby Scott', 'jo.da@abc.com', 50000),
(106, 'Anjali Chouhan', 'JO.DA@ABC.COM', 60000),
(107, 'Ankit Bansal', 'AN.BA@ABC.COM', 70000);

/*
   STEP 3: Create Audit Table
   This table will record all trigger-based logs (insert, delete, update operations)
   performed on the Aud_employee table.
*/
CREATE TABLE Audit_table_employee (
    id INT IDENTITY(1,1),
    audit_text VARCHAR(200),
    audit_timestamp DATETIME
);


/* -------------------------------------------------------------------------------------
   TRIGGER 1: AFTER INSERT
   Description: When a new employee is added, this trigger records the event
   in the Audit_table_employee.
------------------------------------------------------------------------------------- */
CREATE TRIGGER tr_employee_afterinsert
ON Aud_employee
FOR INSERT
AS
BEGIN
    INSERT INTO Audit_table_employee (audit_text, audit_timestamp)
    SELECT 'A new employee added with employee ID ' + CAST(employee_id AS VARCHAR(10)), 
           GETDATE()
    FROM inserted;
END;

/* Test the INSERT trigger */
INSERT INTO Aud_employee VALUES (108, 'Shivam', 'shiv@gmail.com', 5000);
SELECT * FROM Audit_table_employee;


/* -------------------------------------------------------------------------------------
   TRIGGER 2: AFTER DELETE
   Description: When an employee record is deleted, this trigger logs that deletion
   into the audit table.
------------------------------------------------------------------------------------- */
CREATE TRIGGER tr_employee_afterdelete
ON Aud_employee
FOR DELETE
AS
BEGIN
    INSERT INTO Audit_table_employee (audit_text, audit_timestamp)
    SELECT 'An employee deleted with employee ID ' + CAST(employee_id AS VARCHAR(10)), 
           GETDATE()
    FROM deleted;
END;

/* Test the DELETE trigger */
DELETE FROM Aud_employee WHERE employee_id = 101;

/* View Results */
SELECT * FROM Aud_employee;
SELECT * FROM Audit_table_employee;


/* -------------------------------------------------------------------------------------
   TRIGGER 3: AFTER UPDATE
   Description: When employee details are updated, this trigger records
   what exactly changed (name, email, or salary).
------------------------------------------------------------------------------------- */
CREATE TRIGGER tr_employee_update
ON Aud_employee
FOR UPDATE
AS
BEGIN
    INSERT INTO Audit_table_employee (audit_text, audit_timestamp)
    SELECT 
        'An employee details updated with employee ID ' + CAST(i.employee_id AS VARCHAR(10))
        + CASE 
            WHEN i.employee_name != d.employee_name 
            THEN ' | Name changed from ' + d.employee_name + ' to ' + i.employee_name 
            ELSE '' 
          END
        + CASE 
            WHEN i.email_id != d.email_id 
            THEN ' | Email changed from ' + d.email_id + ' to ' + i.email_id 
            ELSE '' 
          END
        + CASE 
            WHEN i.salary != d.salary 
            THEN ' | Salary changed from ' + CAST(d.salary AS VARCHAR(10)) 
                 + ' to ' + CAST(i.salary AS VARCHAR(10)) 
            ELSE '' 
          END,
        GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON i.employee_id = d.employee_id;
END;

/* Test the UPDATE trigger */
UPDATE Aud_employee SET salary = 15425 WHERE employee_id = 103;

/* View final results */
SELECT * FROM Aud_employee;
SELECT * FROM Audit_table_employee;


/* =====================================================================================
   SECTION 2: SQL GROUPING OPERATIONS (GROUP BY, ROLLUP, CUBE)
===================================================================================== */

/* 
   STEP 1: Create payoff_orders Table
   This table stores transaction details by city, country, and continent.
*/
CREATE TABLE payoff_orders (
    Id INT PRIMARY KEY,
    Continent VARCHAR(50),
    Country VARCHAR(100),
    City VARCHAR(100),
    amount INT
);

/*
   STEP 2: Insert Sample Data
   These records simulate sales data across multiple countries and continents.
*/
INSERT INTO payoff_orders (Id, Continent, Country, City, amount) VALUES
(1, 'Asia', 'India', 'Bangalore', 1000),
(2, 'Asia', 'India', 'Chennai', 2000),
(3, 'Asia', 'Japan', 'Tokyo', 4000),
(4, 'Asia', 'Japan', 'Hiroshima', 5000),
(5, 'Europe', 'United Kingdom', 'London', 1000),
(6, 'Europe', 'United Kingdom', 'Manchester', 2000),
(7, 'Europe', 'France', 'Paris', 4000),
(8, 'Europe', 'France', 'Cannes', 5000);

/* View base table */
SELECT * FROM payoff_orders;


/* -------------------------------------------------------------------------------------
   GROUPING WITH ROLLUP
   ROLLUP performs hierarchical aggregation — it summarizes data at multiple levels.
   Example: City → Country → Continent → Grand Total
------------------------------------------------------------------------------------- */
SELECT 
    Continent, 
    Country, 
    City, 
    SUM(amount) AS total_sales
FROM payoff_orders
GROUP BY ROLLUP (Continent, Country, City);


/* -------------------------------------------------------------------------------------
   GROUPING WITH CUBE
   CUBE provides all possible combinations of groupings.
   It shows every subtotal and grand total combination (more detailed than ROLLUP).
------------------------------------------------------------------------------------- */
SELECT 
    Continent, 
    Country, 
    City, 
    SUM(amount) AS total_sales
FROM payoff_orders
GROUP BY CUBE (Continent, Country, City);


/* =====================================================================================
   END OF SCRIPT
   This file demonstrates practical examples of:
   1. DML Triggers in SQL (Insert, Delete, Update)
   2. Advanced Aggregations using ROLLUP and CUBE
===================================================================================== */
