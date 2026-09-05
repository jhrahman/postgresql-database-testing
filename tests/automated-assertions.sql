-- ============================================
-- Automated Database Assertions
-- ============================================

DO $$
DECLARE
    violation_count INTEGER;
BEGIN
    -- DB-001: Verify the expected order details.
    SELECT COUNT(*)
    INTO violation_count
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    JOIN products ON products.product_id = orders.product_id
    WHERE orders.order_id = 1010
      AND customers.name = 'Tanvir Hasan'
      AND products.product_name = 'Wireless Mouse'
      AND orders.quantity = 3
      AND orders.total_amount = 75.00
      AND orders.status = 'completed';

    IF violation_count <> 1 THEN
        RAISE EXCEPTION 'DB-001 failed: expected order 1010 details were not found';
    END IF;

    -- DB-002 and DB-003: Order totals must equal price multiplied by quantity.
    SELECT COUNT(*)
    INTO violation_count
    FROM orders
    JOIN products ON products.product_id = orders.product_id
    WHERE orders.total_amount IS DISTINCT FROM products.price * orders.quantity;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-002/DB-003 failed: % incorrect order total(s)', violation_count;
    END IF;

    -- DB-004: Every completed order must have a paid payment.
    SELECT COUNT(*)
    INTO violation_count
    FROM orders
    WHERE orders.status = 'completed'
      AND NOT EXISTS (
          SELECT 1
          FROM payments
          WHERE payments.order_id = orders.order_id
            AND payments.payment_status = 'paid'
      );

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-004 failed: % completed order(s) do not have a paid payment', violation_count;
    END IF;

    -- DB-005 and DB-006: Every order must reference an existing customer and product.
    SELECT COUNT(*)
    INTO violation_count
    FROM orders
    LEFT JOIN customers ON customers.customer_id = orders.customer_id
    LEFT JOIN products ON products.product_id = orders.product_id
    WHERE customers.customer_id IS NULL
       OR products.product_id IS NULL;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-005/DB-006 failed: % order reference violation(s)', violation_count;
    END IF;

    -- DB-007: Every payment must reference an existing order.
    SELECT COUNT(*)
    INTO violation_count
    FROM payments
    LEFT JOIN orders ON orders.order_id = payments.order_id
    WHERE orders.order_id IS NULL;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-007 failed: % payment reference violation(s)', violation_count;
    END IF;

    -- DB-008: Customer email addresses must be unique.
    SELECT COUNT(*)
    INTO violation_count
    FROM (
        SELECT email
        FROM customers
        GROUP BY email
        HAVING COUNT(*) > 1
    ) duplicate_emails;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-008 failed: % duplicate email group(s)', violation_count;
    END IF;

    -- DB-009: A customer cannot place duplicate orders for the same product on the same date.
    SELECT COUNT(*)
    INTO violation_count
    FROM (
        SELECT customer_id, product_id, order_date
        FROM orders
        GROUP BY customer_id, product_id, order_date
        HAVING COUNT(*) > 1
    ) duplicate_orders;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-009 failed: % duplicate order group(s)', violation_count;
    END IF;

    -- DB-010: Payment amounts must match order totals.
    SELECT COUNT(*)
    INTO violation_count
    FROM payments
    JOIN orders ON orders.order_id = payments.order_id
    WHERE payments.amount IS DISTINCT FROM orders.total_amount;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-010 failed: % payment amount mismatch(es)', violation_count;
    END IF;

    -- DB-011: Every completed order must have a payment record.
    SELECT COUNT(*)
    INTO violation_count
    FROM orders
    LEFT JOIN payments ON payments.order_id = orders.order_id
    WHERE orders.status = 'completed'
      AND payments.payment_id IS NULL;

    IF violation_count <> 0 THEN
        RAISE EXCEPTION 'DB-011 failed: % completed order(s) have no payment record', violation_count;
    END IF;

    RAISE NOTICE 'All automated database assertions passed.';
END $$;