-- ============================================
-- Business Rule Validation Tests
-- ============================================


-- DB-003
-- Find Orders With Incorrect Total Amount
-- Expected: 0 rows

SELECT orders.order_id,
       products.product_name,
       products.price,
       orders.quantity,
       orders.total_amount,
       products.price * orders.quantity AS expected_total
FROM orders
JOIN products
    ON products.product_id = orders.product_id
WHERE orders.total_amount != products.price * orders.quantity;


-- DB-004
-- Find Completed Orders With Unpaid Payments
-- Expected: 0 rows

SELECT orders.order_id,
       orders.status AS order_status,
       payments.payment_status
FROM orders
JOIN payments
    ON orders.order_id = payments.order_id
WHERE orders.status = 'completed'
  AND payments.payment_status != 'paid';