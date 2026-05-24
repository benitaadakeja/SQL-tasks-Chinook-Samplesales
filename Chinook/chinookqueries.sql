SELECT *
FROM customer;

SELECT CustomerId, FirstName, LastName, Country
FROM Customer
LIMIT 10;

SELECT CustomerId, FirstName, LastName, Country
FROM Customer
ORDER BY LastName ASC;

# How many customers per country
SELECT Country,
	COUNT(CustomerId) AS TotalCustomers
FROM Customer
GROUP BY Country
ORDER BY TotalCustomers DESC;

#Total number of customers
SELECT
	COUNT(CustomerId) AS TotalCustomers
FROM customer;

# Average invoice value
SELECT
	AVG(Total) AS avg_invoice_value
FROM invoice;

#Total Revenue
SELECT
	SUM(Total) AS total_revenue
FROM invoice;

# Revenue per country
SELECT
	BillingCountry,
    SUM(Total) AS total_revenue
FROM invoice
GROUP BY BillingCountry
ORDER BY total_revenue DESC;

# Number of Invoices per customer
SELECT CustomerId,
	COUNT(InvoiceId) AS total_invoice
FROM invoice
GROUP BY CustomerId
ORDER BY total_invoice DESC;

# Countries with more than five customers
SELECT
	Country,
    COUNT(CustomerId) AS TotalCustomers
FROM customer
GROUP BY Country
HAVING COUNT(CustomerId) > 5
ORDER BY TotalCustomers DESC;

SELECT 
	c.FirstName,
    c.LastName,
    i.Total
FROM customer c
JOIN invoice i
	ON c.CustomerId = i.CustomerId
LIMIT 10;

# Total revenue per customer
SELECT
	c.CustomerId,
    CONCAT(c.FirstName , ' ' , c.LastName) AS customer_name,
    SUM(i.Total) AS total_revenue
FROM customer c
JOIN invoice i
	ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, customer_name
ORDER BY total_revenue DESC;

# Top selling tracks
SELECT
	t.TrackId,
    t.Name AS track_name,
    COUNT(il.InvoiceLineId) AS times_purchased
FROM track t
JOIN invoiceline il
	ON t.TrackId = il.TrackId
GROUP BY t.TrackId, track_name
ORDER BY times_purchased DESC;

# Top performing artists
SELECT
	ar.ArtistId,
    ar.Name AS ArtistName,
    SUM(il.UnitPrice * il.Quantity) AS total_revenue
FROM artist ar
JOIN album al
	ON ar.ArtistId = al.ArtistId
JOIN track t
	ON al.AlbumId = t.AlbumId
JOIN invoiceline il
	ON t.TrackId = il.TrackId
GROUP BY ar.ArtistId, ArtistName
ORDER BY total_revenue DESC;

# Genre performance analysis
SELECT
	g.GenreId,
    g.Name AS genre_name,
    SUM(il.UnitPrice * il.Quantity) AS total_revenue
FROM genre g
JOIN track t 
	ON g.GenreId = t.GenreId
JOIN invoiceline il
	ON t.TrackId = il.TrackId
GROUP BY g.GenreId, genre_name
ORDER BY total_revenue DESC;

# Average customer spending
SELECT AVG(total_spent) AS avg_customerspend
FROM (
	SELECT
		CustomerId, SUM(Total) AS total_spent
	FROM invoice
    GROUP BY CustomerId
) AS customer_totals;

#Customers that spend above average
SELECT
	CustomerId, total_spent
FROM (
	SELECT
		CustomerId, SUM(Total) AS total_spent
	FROM invoice
    GROUP BY CustomerId
) AS customer_totals
WHERE total_spent > (
	SELECT AVG(total_spent)
    FROM (
		SELECT CustomerId, SUM(Total) AS total_spent
        FROM invoice
        GROUP BY CustomerId
	) AS Subtotals
) 
ORDER BY total_spent DESC;

# Customers by total spending
SELECT
	CustomerId, SUM(Total) AS total_spent
FROM invoice
GROUP BY CustomerId;

# Let's add ranking
SELECT CustomerId, total_spent,
	RANK() OVER(ORDER BY total_spent DESC) AS spending_rank
FROM(
	SELECT CustomerId,
		SUM(Total) AS total_spent
	FROM invoice
    GROUP BY CustomerId
) AS customer_totals;

# Customers rank per country
SELECT
	c.Country, c.CustomerId,
    SUM(i.Total) AS total_spent,
    RANK() OVER (
		PARTITION BY c.Country
        ORDER BY SUM(i.Total) DESC
	) AS country_rank
FROM customer c 
JOIN invoice i 
	ON c.CustomerId = i.CustomerId
GROUP BY c.Country, c.CustomerId;

# top 10 customers
SELECT
	c.CustomerId, CONCAT(c.FirstName , ' ', c.LastName) AS CustomerName,
    SUM(i.Total) AS total_spent,
    RANK () OVER(ORDER BY SUM(i.Total) DESC) AS customer_rank
FROM customer c 
JOIN invoice i 
	ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, CustomerName
ORDER BY total_spent DESC
LIMIT 10;

# revenue by country
SELECT 
	c.Country, SUM(i.Total) AS total_revenue,
    COUNT(DISTINCT c.CustomerId) AS total_customers,
    ROUND(SUM(i.Total)/COUNT(DISTINCT c.CustomerId),2) AS revenue_per_customer
FROM customer c 
JOIN invoice i 
	ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY total_revenue DESC;

# monthly revenue
SELECT
	DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    SUM(Total) AS monthly_revenue,
    COUNT(InvoiceId) AS total_invoices
FROM invoice
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY Month;