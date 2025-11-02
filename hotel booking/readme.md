# 🏨 Hotel Booking Data Analysis (SQL Project)

## 📘 Project Overview
This project focuses on analyzing hotel booking data using **SQL** to answer various **real-world business questions** such as customer trends, revenue insights, and occupancy rates.  

The queries explore multiple SQL concepts including:
- Joins  
- Common Table Expressions (CTEs)  
- Window functions  
- Aggregations and groupings  
- Recursive queries  
- Conditional filtering and subqueries  

---

## 🧠 Objectives
To extract actionable insights for hotel management teams, including:
- Understanding customer behavior  
- Analyzing booking patterns by city, gender, and generation  
- Calculating revenue contributions and occupancy rates  
- Identifying top-performing hotels and booking channels  

---

## 🗂️ Dataset Description
The analysis assumes the following **database schema**:

| Table | Description | Key Columns |
|--------|--------------|--------------|
| **customers** | Stores customer demographic details | `customer_id`, `name`, `gender`, `dob`, `city_id` |
| **hotels** | Contains hotel-level details | `id`, `name`, `city_id`, `capacity` |
| **cities** | City-to-state mapping | `id`, `city_name`, `state` |
| **bookings / hotel_bookings** | Core booking data | `booking_id`, `hotel_id`, `customer_id`, `booking_date`, `stay_start_date`, `number_of_nights`, `per_night_rate`, `booking_channel` |

---

## ⚙️ Technologies Used
- **SQL Server (T-SQL)** — Primary query language  
- **CTEs and Recursive CTEs** — For advanced data transformations  
- **Window Functions** — Ranking, percentage share, etc.  
- **Aggregate Functions** — SUM, COUNT, AVG, etc.  
- **Joins** — INNER, LEFT, and derived table joins  

---

## 📊 Key Analyses Performed

### 1️⃣ Top Customers (Same City Bookings)
> Find top 5 customers who made the most bookings in their own city.

### 2️⃣ Female Contribution to Revenue
> Percentage of revenue and bookings by female customers for each hotel.

### 3️⃣ Daily Occupancy Expansion (Recursive CTE)
> Flatten stay data to generate one record per guest per day of stay.

### 4️⃣ Maximum Occupancy Date per Hotel
> Identify dates when each hotel had the highest occupancy.

### 5️⃣ Multi-State Travelers
> Customers who booked hotels in **3 or more different states**.

### 6️⃣ Monthly Occupancy Rate
> Calculate percentage of rooms occupied for each hotel monthly.

### 7️⃣ Fully Occupied Dates
> Find days when hotels were **100% full**.

### 8️⃣ Top Booking Channel per Month
> Detect which booking channel generated the highest sales each month.

### 9️⃣ Booking Channel Share
> Determine booking percentage by each channel.

### 🔟 Revenue by Generation
> Compare **Millennials (1980-1996)** vs **Gen Z (after 1996)** contributions.

### 11️⃣ Average Stay Duration
> Average number of nights per hotel.

### 12️⃣ Advance Booking Trend
> Average number of days between booking and stay start.

### 13️⃣ Inactive Customers
> Customers who never made any bookings.

### 14️⃣ Multi-Hotel Travelers in One Month
> Customers who stayed in **3+ distinct hotels** within the same month.

---

## 📁 File Structure
