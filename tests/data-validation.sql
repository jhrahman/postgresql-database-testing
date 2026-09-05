-- ============================================
-- Data Validation Tests
-- ============================================


-- DB-001
-- Verify Order Details
-- Expected: Order 1010 should return the expected
-- customer, product, quantity, total and status.

SELECT customers.name AS customer_name,
       products.product_name,
       orders.quantity,
       orders.total_amount,
       orders.status
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN products
    ON products.product_id = orders.product_id
WHERE orders.order_id = 1010;


-- DB-002
-- Verify Order Total Calculation
-- Business Rule:
-- total_amount = product price × quantity

SELECT orders.order_id,
       products.product_name,
       products.price,
       orders.quantity,
       orders.total_amount,
       products.price * orders.quantity AS expected_total
FROM orders
JOIN products
    ON products.product_id = orders.product_id
WHERE orders.order_id = 1010;