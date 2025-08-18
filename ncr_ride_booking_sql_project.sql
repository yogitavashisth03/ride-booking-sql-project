--List all the distinct vehicle types available--
SELECT DISTINCT vehicle_type 
FROM ncr_ride_booking_s



--Show the first 10 completed bookings with their booking value, distance, and payment method--

SELECT booking_id, customer_id, booking_date, booking_value, ride_distance, payment_method
FROM ncr_ride_booking_s
ORDER BY booking_date
LIMIT 10



--Count the total number of bookings per booking status (Completed, Incomplete, No Driver Found, etc.)--

SELECT booking_status, COUNT(*) AS number_of_bookins
FROM ncr_ride_booking_s
GROUP BY booking_status



--Find the top 5 pickup locations with the highest number of bookings--

SELECT pickup_location, COUNT(*) AS number_of_bookings
FROM ncr_ride_booking_s
GROUP BY pickup_location
ORDER BY number_of_bookings DESC
LIMIT 5



--Get the total booking value generated each day--

SELECT booking_date, SUM(booking_value) AS booking_value 
FROM ncr_ride_booking_s
GROUP BY booking_date
ORDER BY booking_date DESC



--Find the average ride distance and booking value for each vehicle type--

SELECT vehicle_type, ROUND(AVG(ride_distance),2) AS avg_ride_distance,
ROUND(AVG(booking_value),2) AS avg_booking_value
FROM ncr_ride_booking_s
GROUP BY vehicle_type



--Count how many rides were cancelled by customers vs. drivers--

SELECT COUNT(CASE WHEN
                  cancelled_rides_cust IS NOT NULL
				  THEN cancelled_rides_cust END) AS rides_cancelled_by_customer,
	   COUNT(CASE WHEN
                  cancelled_rides_driver IS NOT NULL
				  THEN cancelled_rides_driver END) AS rides_cancelled_by_driver
FROM ncr_ride_booking_s



--Find the most common reason for cancellation by customers and by drivers--

SELECT (SELECT cust_cancellation_rsn
        FROM ncr_ride_booking_s
		WHERE cust_cancellation_rsn!='null'
		GROUP BY cust_cancellation_rsn
		ORDER BY COUNT(*)
		LIMIT 1) AS most_common_cancellation_rsn_by_customer,
		(SELECT driver_cancellation_rsn
        FROM ncr_ride_booking_s
		WHERE driver_cancellation_rsn!='null'
		GROUP BY driver_cancellation_rsn
		ORDER BY COUNT(*)
		LIMIT 1) AS most_common_cancellation_rsn_by_driver;



--Find the average customer rating and driver rating by vehicle type--

SELECT vehicle_type, ROUND(AVG(customer_rating), 1) AS avg_cust_rating,
                     ROUND(AVG(driver_rating),1) AS avg_driver_rating
FROM ncr_ride_booking_s
GROUP BY vehicle_type



--For each payment method, find the total completed rides and total revenue--

SELECT payment_method, COUNT(CASE WHEN
                                  booking_status='Completed'
								  THEN booking_status END) AS total_completed_rides,
					   SUM(CASE WHEN
                                  booking_status='Completed'
								  THEN booking_value END) AS total_revenue
FROM ncr_ride_booking_s
WHERE payment_method!='null'
GROUP BY payment_method



--Find the top 3 customers who spent the most on rides--

SELECT customer_id
FROM ncr_ride_booking_s 
GROUP BY customer_id
ORDER BY SUM(booking_value) DESC
LIMIT 3



--Identify the driver cancellation rate: (Cancelled rides by driver) / (Total bookings)--

SELECT ROUND(COUNT(CASE WHEN 
                  booking_status='Cancelled by Driver'
				  THEN booking_status END)*1.0/COUNT(booking_status),2) AS driver_cancellation_rate
FROM ncr_ride_booking_s



--Find the average booking value per km for each vehicle type--

SELECT vehicle_type, ROUND(AVG(booking_value/ride_distance),2)
FROM ncr_ride_booking_s
GROUP BY vehicle_type



--Using window functions: rank customers by total number of completed rides--

SELECT customer_id, RANK() OVER 
                              (PARTITION BY customer_id 
							  ORDER BY 
							  COUNT(CASE 
                                       WHEN booking_status='Completed'
							           THEN booking_status END) DESC) AS rnk
FROM ncr_ride_booking_s
GROUP BY customer_id
ORDER BY rnk



--Find the monthly trend of completed rides (e.g., March 2024 vs April 2024)--

SELECT booking_month, COUNT(*)
FROM 
(SELECT *, TO_CHAR(booking_date, 'FMMONTH') AS booking_month
FROM ncr_ride_booking_s) AS t
WHERE booking_month='MARCH'
      OR booking_month='APRIL'
GROUP BY booking_month



--Which pickup–drop route pair has the highest revenue?--

SELECT pickup_location, drop_location, SUM(booking_value) AS revenue
FROM ncr_ride_booking_s
WHERE drop_location!='null'
     AND pickup_location!='null'
	 AND booking_status='Completed'
GROUP BY pickup_location, drop_location
ORDER BY revenue DESC
LIMIT 1



--Find the peak booking hours of the day--

SELECT EXTRACT(HOUR FROM booking_time) AS peak_hours, COUNT(*) AS bookings
FROM ncr_ride_booking_s
GROUP BY  peak_hours
ORDER BY bookings DESC
LIMIT 5



--Calculate the average waiting time (VTAT) vs. travel time (CTAT) for completed rides--

SELECT ROUND(AVG(avg_tat),1) AS avg_waiting_time, ROUND(AVG(avg_ctat),1) AS avg_tarvel_time
FROM ncr_ride_booking_s
WHERE booking_status='Completed'



--Identify locations with the highest number of incomplete rides--

SELECT pickup_location, COUNT(*) AS number_of_rides
FROM ncr_ride_booking_s
WHERE booking_status='Incomplete'
GROUP BY pickup_location
ORDER BY number_of_rides DESC