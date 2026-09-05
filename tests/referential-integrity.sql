-- ============================================
-- Referential Integrity Tests
-- ============================================


-- DB-005
-- Find Orders With Invalid Customer References
-- Expected: 0 rows

SELECT orders.order_id,
       orders.customer_id
FROM orders
LEFT JOIN customers
    ON orders.customer_id = customers.customer_id
WHERE customers.customer_id IS NULL;


-- DB-006
-- Find Orders With Invalid Product References
-- Expected: 0 rows

SELECT orders.order_id,
       orders.product_id
FROM orders
LEFT JOIN products
    ON orders.product_id = products.product_id
WHERE products.product_id IS NULL;


-- DB-007
-- Find Payments With Invalid Order References
-- Expected: 0 rows

SELECT payments.payment_id,
       payments.order_id
FROM payments
LEFT JOIN orders
    ON payments.order_id = orders.order_id
WHERE orders.order_id IS NULL;