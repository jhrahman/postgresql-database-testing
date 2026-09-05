-- ============================================
-- Duplicate Data Tests
-- ============================================


-- DB-008
-- Find Duplicate Customer Emails
-- Expected: 0 rows

SELECT email,
       COUNT(*) AS email_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;


-- DB-009
-- Find Duplicate Orders
-- Business Rule:
-- customer_id + product_id + order_date
-- should be unique.
-- Expected: 0 rows

SELECT customer_id,
       product_id,
       order_date,
       COUNT(*) AS order_count
FROM orders
GROUP BY customer_id,
         product_id,
         order_date
HAVING COUNT(*) > 1;