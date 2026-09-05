-- ============================================
-- Data Reconciliation Tests
-- ============================================


-- DB-010
-- Find Payment Amounts That Do Not Match
-- The Corresponding Order Total
-- Expected: 0 rows

SELECT orders.order_id,
       orders.total_amount AS order_total,
       payments.amount AS payment_amount
FROM orders
JOIN payments
    ON orders.order_id = payments.order_id
WHERE payments.amount != orders.total_amount;


-- DB-011
-- Find Completed Orders Without Payment Records
-- Expected: 0 rows

SELECT orders.order_id,
       orders.status
FROM orders
LEFT JOIN payments
    ON orders.order_id = payments.order_id
WHERE orders.status = 'completed'
  AND payments.payment_id IS NULL;