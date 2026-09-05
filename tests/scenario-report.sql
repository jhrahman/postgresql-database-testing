-- Machine-readable scenario results for the CI report.
-- Columns: id, category, title, status, expected, actual

WITH
db001 AS (
    SELECT COUNT(*) AS matches
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    JOIN products ON products.product_id = orders.product_id
    WHERE orders.order_id = 1010
      AND customers.name = 'Tanvir Hasan'
      AND products.product_name = 'Wireless Mouse'
      AND orders.quantity = 3
      AND orders.total_amount = 75.00
      AND orders.status = 'completed'
),
db002 AS (
    SELECT COUNT(*) AS matches
    FROM orders
    JOIN products ON products.product_id = orders.product_id
    WHERE orders.order_id = 1010
      AND orders.total_amount IS NOT DISTINCT FROM products.price * orders.quantity
),
db003 AS (
    SELECT COUNT(*) AS violations
    FROM orders
    JOIN products ON products.product_id = orders.product_id
    WHERE orders.total_amount IS DISTINCT FROM products.price * orders.quantity
),
db004 AS (
    SELECT COUNT(*) AS violations
    FROM orders
    WHERE orders.status = 'completed'
      AND NOT EXISTS (
          SELECT 1
          FROM payments
          WHERE payments.order_id = orders.order_id
            AND payments.payment_status = 'paid'
      )
),
db005 AS (
    SELECT COUNT(*) AS violations
    FROM orders
    LEFT JOIN customers ON customers.customer_id = orders.customer_id
    WHERE customers.customer_id IS NULL
),
db006 AS (
    SELECT COUNT(*) AS violations
    FROM orders
    LEFT JOIN products ON products.product_id = orders.product_id
    WHERE products.product_id IS NULL
),
db007 AS (
    SELECT COUNT(*) AS violations
    FROM payments
    LEFT JOIN orders ON orders.order_id = payments.order_id
    WHERE orders.order_id IS NULL
),
db008 AS (
    SELECT COUNT(*) AS violations
    FROM (
        SELECT email
        FROM customers
        GROUP BY email
        HAVING COUNT(*) > 1
    ) duplicate_emails
),
db009 AS (
    SELECT COUNT(*) AS violations
    FROM (
        SELECT customer_id, product_id, order_date
        FROM orders
        GROUP BY customer_id, product_id, order_date
        HAVING COUNT(*) > 1
    ) duplicate_orders
),
db010 AS (
    SELECT COUNT(*) AS violations
    FROM payments
    JOIN orders ON orders.order_id = payments.order_id
    WHERE payments.amount IS DISTINCT FROM orders.total_amount
),
db011 AS (
    SELECT COUNT(*) AS violations
    FROM orders
    LEFT JOIN payments ON payments.order_id = orders.order_id
    WHERE orders.status = 'completed'
      AND payments.payment_id IS NULL
)
SELECT 'DB-001', 'Data validation', 'Verify order details',
       CASE WHEN matches = 1 THEN 'PASS' ELSE 'FAIL' END,
       'Order 1010 matches the expected customer, product, quantity, total, and status',
       matches || ' matching record(s)'
FROM db001
UNION ALL
SELECT 'DB-002', 'Data validation', 'Verify order total calculation',
       CASE WHEN matches = 1 THEN 'PASS' ELSE 'FAIL' END,
       'Order 1010 total equals product price multiplied by quantity',
       matches || ' matching calculation(s)'
FROM db002
UNION ALL
SELECT 'DB-003', 'Business rules', 'Find incorrect order totals',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 incorrect order totals',
       violations || ' violation(s) found'
FROM db003
UNION ALL
SELECT 'DB-004', 'Business rules', 'Validate completed order payments',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 completed orders without a paid payment',
       violations || ' violation(s) found'
FROM db004
UNION ALL
SELECT 'DB-005', 'Referential integrity', 'Validate customer references',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 orders with invalid customer references',
       violations || ' violation(s) found'
FROM db005
UNION ALL
SELECT 'DB-006', 'Referential integrity', 'Validate product references',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 orders with invalid product references',
       violations || ' violation(s) found'
FROM db006
UNION ALL
SELECT 'DB-007', 'Referential integrity', 'Validate payment references',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 payments with invalid order references',
       violations || ' violation(s) found'
FROM db007
UNION ALL
SELECT 'DB-008', 'Duplicate data', 'Detect duplicate customer emails',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 duplicate email groups',
       violations || ' violation group(s) found'
FROM db008
UNION ALL
SELECT 'DB-009', 'Duplicate data', 'Detect duplicate orders',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 duplicate customer/product/date groups',
       violations || ' violation group(s) found'
FROM db009
UNION ALL
SELECT 'DB-010', 'Data reconciliation', 'Reconcile payment amounts',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 payment amount mismatches',
       violations || ' violation(s) found'
FROM db010
UNION ALL
SELECT 'DB-011', 'Data reconciliation', 'Find completed orders without payments',
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END,
       '0 completed orders without payment records',
       violations || ' violation(s) found'
FROM db011
ORDER BY 1;