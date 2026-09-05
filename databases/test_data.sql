-- ============================================
-- PostgreSQL Database Testing Project
-- Sample Test Data
-- ============================================


-- ============================================
-- Customers
-- ============================================

INSERT INTO customers
(customer_id, name, email, city, country, signup_date, status)
VALUES
(1, 'Rahim Ahmed', 'rahim@example.com', 'Dhaka', 'Bangladesh', '2025-01-15', 'active'),
(2, 'Sarah Khan', 'sarah@example.com', 'Chittagong', 'Bangladesh', '2025-02-10', 'active'),
(3, 'John Smith', 'john@example.com', 'London', 'UK', '2025-02-20', 'active'),
(4, 'Maria Garcia', 'maria@example.com', 'Madrid', 'Spain', '2025-03-05', 'inactive'),
(5, 'David Lee', 'david@example.com', 'Singapore', 'Singapore', '2025-03-18', 'active'),
(6, 'Nadia Islam', 'nadia@example.com', 'Dhaka', 'Bangladesh', '2025-04-01', 'active'),
(7, 'Alex Brown', 'alex@example.com', 'New York', 'USA', '2025-04-15', 'inactive'),
(8, 'Tanvir Hasan', 'tanvir@example.com', 'Dhaka', 'Bangladesh', '2025-05-10', 'active'),
(9, 'Emma Wilson', 'emma@example.com', 'London', 'UK', '2025-05-20', 'active'),
(10, 'Michael Chen', 'michael@example.com', 'Toronto', 'Canada', '2025-06-01', 'active');


-- ============================================
-- Products
-- ============================================

INSERT INTO products
(product_id, product_name, category, price, stock_quantity)
VALUES
(101, 'Laptop Pro 14', 'Electronics', 1200.00, 15),
(102, 'Wireless Mouse', 'Electronics', 25.00, 100),
(103, 'Mechanical Keyboard', 'Electronics', 80.00, 50),
(104, 'USB-C Hub', 'Accessories', 45.00, 70),
(105, 'Monitor 24 inch', 'Electronics', 220.00, 25),
(106, 'Laptop Stand', 'Accessories', 60.00, 40),
(107, 'Office Chair', 'Furniture', 180.00, 12),
(108, 'Desk Lamp', 'Furniture', 35.00, 60),
(109, 'Webcam HD', 'Electronics', 75.00, 30),
(110, 'Headphones', 'Audio', 95.00, 45);


-- ============================================
-- Orders
-- ============================================

INSERT INTO orders
(order_id, customer_id, product_id, order_date, quantity, total_amount, status)
VALUES
(1001, 1, 101, '2025-06-05', 1, 1200.00, 'completed'),
(1002, 1, 102, '2025-06-06', 2, 50.00, 'completed'),
(1003, 2, 105, '2025-06-07', 1, 220.00, 'completed'),
(1004, 3, 103, '2025-06-08', 1, 80.00, 'pending'),
(1005, 4, 107, '2025-06-09', 2, 360.00, 'cancelled'),
(1006, 5, 110, '2025-06-10', 1, 95.00, 'completed'),
(1007, 6, 104, '2025-06-11', 2, 90.00, 'completed'),
(1008, 6, 106, '2025-06-12', 1, 60.00, 'completed'),
(1009, 8, 109, '2025-06-13', 2, 150.00, 'pending'),
(1010, 8, 102, '2025-06-14', 3, 75.00, 'completed'),
(1011, 9, 101, '2025-06-15', 1, 1200.00, 'completed'),
(1012, 10, 108, '2025-06-16', 2, 70.00, 'completed'),
(1013, 2, 103, '2025-06-17', 2, 160.00, 'completed'),
(1014, 3, 105, '2025-06-18', 1, 220.00, 'completed'),
(1015, 5, 102, '2025-06-19', 4, 100.00, 'completed'),
(1016, 7, 107, '2025-06-20', 1, 180.00, 'cancelled'),
(1017, 10, 110, '2025-06-21', 1, 95.00, 'pending'),
(1018, 1, 104, '2025-06-22', 1, 45.00, 'completed');


-- ============================================
-- Payments
-- ============================================

INSERT INTO payments
(payment_id, order_id, payment_date, payment_method, amount, payment_status)
VALUES
(5001, 1001, '2025-06-05', 'Credit Card', 1200.00, 'paid'),
(5002, 1002, '2025-06-06', 'PayPal', 50.00, 'paid'),
(5003, 1003, '2025-06-07', 'Credit Card', 220.00, 'paid'),
(5004, 1004, '2025-06-08', 'Credit Card', 80.00, 'pending'),
(5005, 1005, '2025-06-09', 'Credit Card', 360.00, 'refunded'),
(5006, 1006, '2025-06-10', 'Bank Transfer', 95.00, 'paid'),
(5007, 1007, '2025-06-11', 'Credit Card', 90.00, 'paid'),
(5008, 1008, '2025-06-12', 'PayPal', 60.00, 'paid'),
(5009, 1009, '2025-06-13', 'Credit Card', 150.00, 'pending'),
(5010, 1010, '2025-06-14', 'PayPal', 75.00, 'paid'),
(5011, 1011, '2025-06-15', 'Credit Card', 1200.00, 'paid'),
(5012, 1012, '2025-06-16', 'Bank Transfer', 70.00, 'paid'),
(5013, 1013, '2025-06-17', 'Credit Card', 160.00, 'paid'),
(5014, 1014, '2025-06-18', 'Credit Card', 220.00, 'paid'),
(5015, 1015, '2025-06-19', 'PayPal', 100.00, 'paid'),
(5016, 1016, '2025-06-20', 'Credit Card', 180.00, 'refunded'),
(5017, 1017, '2025-06-21', 'Credit Card', 95.00, 'pending'),
(5018, 1018, '2025-06-22', 'Bank Transfer', 45.00, 'paid');