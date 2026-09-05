# PostgreSQL Database Test Cases

## 1. Data Validation

### DB-001 — Verify Order Details

**Objective:**
Verify that an order contains the correct customer, product, quantity, total amount, and status.

**Test Data:**
Order ID: `1010`

**Expected Result:**
Order `1010` should belong to Tanvir Hasan, contain Wireless Mouse, have quantity `3`, total amount `75.00`, and status `completed`.

**Validation:**
Retrieve the order information by joining `customers`, `orders`, and `products` and compare the database values against the expected data.

---

### DB-002 — Verify Order Total Calculation

**Objective:**
Verify that the order total is correctly calculated using the product price and ordered quantity.

**Business Rule:**

```text
Order Total = Product Price × Quantity
```

**Test Data:**
Order ID: `1010`

**Expected Result:**
The stored `total_amount` should equal `products.price × orders.quantity`.

For order `1010`:

```text
25.00 × 3 = 75.00
```

---

## 2. Business Rule Validation

### DB-003 — Find Incorrect Order Totals

**Objective:**
Identify orders where the stored total amount does not match the expected calculation.

**Business Rule:**

```text
total_amount = product price × quantity
```

**Expected Result:**
The query should return only orders where the stored total is incorrect.

**Pass Criteria:**
No records should be returned when all order totals are correct.

---

### DB-004 — Validate Completed Order Payment Status

**Objective:**
Verify that completed orders have a corresponding payment with a `paid` status.

**Business Rule:**

```text
Order status = completed
Payment status = paid
```

**Expected Result:**
No completed order should have a payment status other than `paid`.

---

## 3. Referential Integrity

### DB-005 — Validate Customer References

**Objective:**
Verify that every order references an existing customer.

**Expected Result:**
Every `orders.customer_id` should exist in `customers.customer_id`.

**Pass Criteria:**
The validation query should return zero records.

---

### DB-006 — Validate Product References

**Objective:**
Verify that every order references an existing product.

**Expected Result:**
Every `orders.product_id` should exist in `products.product_id`.

**Pass Criteria:**
The validation query should return zero records.

---

### DB-007 — Validate Payment Order References

**Objective:**
Verify that every payment belongs to an existing order.

**Expected Result:**
Every `payments.order_id` should exist in `orders.order_id`.

**Pass Criteria:**
The validation query should return zero records.

---

## 4. Duplicate Data Validation

### DB-008 — Detect Duplicate Customer Emails

**Objective:**
Identify duplicate customer email addresses.

**Business Rule:**

```text
Each customer email should be unique.
```

**Expected Result:**
No email address should appear more than once.

**Pass Criteria:**
The query should return zero duplicate email records.

---

### DB-009 — Detect Duplicate Orders

**Objective:**
Identify multiple orders placed by the same customer for the same product on the same date.

**Business Rule:**

```text
customer_id + product_id + order_date
```

should be unique.

**Expected Result:**
No duplicate combination should exist.

**Pass Criteria:**
The query should return zero records.

---

## 5. Data Reconciliation

### DB-010 — Reconcile Order and Payment Amounts

**Objective:**
Verify that the payment amount matches the corresponding order total.

**Business Rule:**

```text
Payment Amount = Order Total Amount
```

**Expected Result:**
The payment amount should match the order's `total_amount`.

**Pass Criteria:**
No mismatched records should be returned.

---

### DB-011 — Identify Completed Orders Without Payment Records

**Objective:**
Identify completed orders that do not have a corresponding payment record.

**Business Rule:**

```text
Every completed order must have a payment record.
```

**Expected Result:**
Every completed order should have a matching record in `payments`.

**Pass Criteria:**
The query should return zero records.

---

## Test Execution Approach

For each database test:

1. Execute the SQL validation query.
2. Review the returned records.
3. Compare the actual database state against the business rule.
4. If unexpected records are returned, investigate the data.
5. Raise a defect if the database contains invalid or inconsistent data.

## Expected Result Convention

For data-integrity validation queries, a **zero-row result normally indicates that no violation was found**.

For data-retrieval tests such as DB-001, the returned values should be compared against the expected business data.
