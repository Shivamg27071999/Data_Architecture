/*****************************************************************************************
🎯 PROJECT: Hotel Booking Data Analysis (SQL Case Study)
📘 AUTHOR: Shivam
📅 DESCRIPTION: Collection of analytical SQL queries for hotel booking dataset.
******************************************************************************************/

-------------------------------------------------------------------------------------------
-- 1️⃣  Find top 5 customers who made the most number of bookings 
--      in the same city where they live.
--      Display: customer_id and % of such bookings vs their total bookings
-------------------------------------------------------------------------------------------

SELECT TOP 5 
    b.customer_id,
    COUNT(*) AS total_bookings,
    COUNT(CASE WHEN c.city_id = h.city_id THEN booking_id END) AS same_city_bookings,
    COUNT(CASE WHEN c.city_id = h.city_id THEN booking_id END) * 100.0 / COUNT(*) AS percent_same_city
FROM bookings b
INNER JOIN customers c ON b.customer_id = c.customer_id
INNER JOIN hotels h ON h.id = b.hotel_id
GROUP BY b.customer_id
ORDER BY same_city_bookings DESC;


-------------------------------------------------------------------------------------------
-- 2️⃣  Find percent contribution by females in terms of 
--      both revenue and number of bookings for each hotel.
-------------------------------------------------------------------------------------------

WITH total_booking AS (
    SELECT 
        hotel_id,
        COUNT(*) AS total_bookings,
        SUM(per_night_rate * number_of_nights) AS total_revenue
    FROM bookings
    GROUP BY hotel_id
),
female_booking AS (
    SELECT 
        b.hotel_id,
        COUNT(*) AS female_bookings,
        SUM(per_night_rate * number_of_nights) AS female_revenue
    FROM bookings b
    INNER JOIN customers c ON c.customer_id = b.customer_id
    WHERE c.gender = 'F'
    GROUP BY b.hotel_id
)
SELECT 
    t.hotel_id,
    f.female_bookings,
    t.total_bookings,
    t.total_revenue,
    f.female_revenue,
    (f.female_bookings * 100.0 / t.total_bookings) AS booking_percentage,
    (f.female_revenue * 100.0 / t.total_revenue) AS revenue_percentage
FROM total_booking t
INNER JOIN female_booking f ON f.hotel_id = t.hotel_id;


-------------------------------------------------------------------------------------------
-- 3️⃣  Expand hotel bookings day-wise using Recursive CTE 
--      to find daily occupancy or per-day insights.
-------------------------------------------------------------------------------------------

-- STEP 1: Calculate stay duration for each booking
WITH cte AS (
    SELECT 
        hotel_id,
        customer_id,
        stay_start_date AS start_date,
        DATEADD(DAY, number_of_nights - 1, stay_start_date) AS end_date
    FROM hotel_bookings
),

-- STEP 2: Expand booking into multiple rows (one per stay date)
rcte AS (
    SELECT hotel_id, customer_id, start_date AS stay_date, end_date FROM cte
    UNION ALL
    SELECT hotel_id, customer_id, DATEADD(DAY, 1, stay_date), end_date
    FROM rcte
    WHERE DATEADD(DAY, 1, stay_date) <= end_date
)

-- STEP 3: Store the flattened data into a new table
SELECT * 
INTO hotel_bookings_flatten
FROM rcte;

-- STEP 4: Verify the flattened data
SELECT * FROM hotel_bookings_flatten;


-------------------------------------------------------------------------------------------
-- 4️⃣  Find the date when occupancy was maximum for each hotel
-------------------------------------------------------------------------------------------

SELECT *
FROM (
    SELECT 
        hotel_id,
        stay_date,
        COUNT(*) AS no_of_guests,
        RANK() OVER (PARTITION BY hotel_id ORDER BY COUNT(*) DESC) AS rn
    FROM hotel_bookings_flatten
    GROUP BY hotel_id, stay_date
) ranked
WHERE rn = 1;


-------------------------------------------------------------------------------------------
-- 5️⃣  Find customers who have booked hotels in at least 3 different states
-------------------------------------------------------------------------------------------

SELECT hb.customer_id
FROM bookings hb
INNER JOIN hotels h ON hb.hotel_id = h.id 
INNER JOIN cities c ON h.city_id = c.id
GROUP BY hb.customer_id
HAVING COUNT(DISTINCT c.state) >= 3;


-------------------------------------------------------------------------------------------
-- 6️⃣  Calculate Occupancy Rate (%) for each hotel for each month
-------------------------------------------------------------------------------------------

WITH cte AS (
    SELECT 
        hb.hotel_id,
        hb.stay_date,
        COUNT(*) AS no_of_guests,
        h.capacity
    FROM hotel_bookings_flatten hb
    INNER JOIN hotels h ON hb.hotel_id = h.id
    GROUP BY hb.hotel_id, hb.stay_date, h.capacity
)
SELECT 
    hotel_id,
    MONTH(stay_date) AS stay_month,
    SUM(no_of_guests) * 100.0 / SUM(capacity) AS occupancy_rate
FROM cte
GROUP BY hotel_id, MONTH(stay_date);


-------------------------------------------------------------------------------------------
-- 7️⃣  Find dates when hotels were fully occupied
-------------------------------------------------------------------------------------------

WITH cte AS (
    SELECT hotel_id, stay_date, COUNT(*) AS no_of_guests 
    FROM hotel_bookings_flatten
    GROUP BY hotel_id, stay_date
)
SELECT cte.*, h.capacity
FROM cte
INNER JOIN hotels h ON cte.hotel_id = h.id
WHERE cte.no_of_guests = h.capacity;


-------------------------------------------------------------------------------------------
-- 8️⃣  Identify booking channel with highest sales for each hotel per month
-------------------------------------------------------------------------------------------

WITH cte AS (
    SELECT 
        hotel_id,
        booking_channel,
        FORMAT(booking_date, 'yyyyMM') AS booking_month,
        SUM(number_of_nights * per_night_rate) AS revenue
    FROM hotel_bookings
    GROUP BY hotel_id, booking_channel, FORMAT(booking_date, 'yyyyMM')
)
SELECT * 
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY hotel_id, booking_month ORDER BY revenue DESC) AS rn
    FROM cte
) ranked
WHERE rn = 1;


-------------------------------------------------------------------------------------------
-- 9️⃣  Find % share of number of bookings by each booking channel
-------------------------------------------------------------------------------------------

SELECT 
    booking_channel,
    COUNT(*) AS no_of_bookings,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percent_share
FROM hotel_bookings
GROUP BY booking_channel;


-------------------------------------------------------------------------------------------
-- 🔟  Revenue by Millennials (1980–1996) and Gen Z (after 1996)
-------------------------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN YEAR(c.dob) BETWEEN 1980 AND 1996 THEN 'Millennials'
        WHEN YEAR(c.dob) > 1996 THEN 'Gen Z'
    END AS customer_category,
    SUM(per_night_rate * number_of_nights) AS total_revenue
FROM hotel_bookings hb
INNER JOIN customers c ON hb.customer_id = c.customer_id
GROUP BY 
    CASE 
        WHEN YEAR(c.dob) BETWEEN 1980 AND 1996 THEN 'Millennials'
        WHEN YEAR(c.dob) > 1996 THEN 'Gen Z'
    END;


-------------------------------------------------------------------------------------------
-- 11️⃣  Average stay duration per hotel
-------------------------------------------------------------------------------------------

SELECT 
    hotel_id,
    AVG(number_of_nights * 1.0) AS avg_stay_duration
FROM hotel_bookings
GROUP BY hotel_id;


-------------------------------------------------------------------------------------------
-- 12️⃣  Average number of days customers book in advance (per hotel)
-------------------------------------------------------------------------------------------

SELECT 
    hotel_id,
    AVG(DATEDIFF(DAY, booking_date, stay_start_date) * 1.0) AS avg_days_in_advance
FROM hotel_bookings
GROUP BY hotel_id;


-------------------------------------------------------------------------------------------
-- 13️⃣  Customers who never made any booking
-------------------------------------------------------------------------------------------

SELECT * 
FROM customers
WHERE customer_id NOT IN (SELECT customer_id FROM hotel_bookings);


-------------------------------------------------------------------------------------------
-- 14️⃣  Customers who stayed in at least 3 distinct hotels in the same month
-------------------------------------------------------------------------------------------

SELECT 
    customer_id,
    MONTH(stay_date) AS stay_month,
    COUNT(DISTINCT hotel_id) AS distinct_hotels
FROM hotel_bookings_flatten
GROUP BY customer_id, MONTH(stay_date)
HAVING COUNT(DISTINCT hotel_id) >= 3
ORDER BY distinct_hotels DESC;

-------------------------------------------------------------------------------------------
-- ✅ END OF SCRIPT
-------------------------------------------------------------------------------------------
