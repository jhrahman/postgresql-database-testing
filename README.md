# PostgreSQL Database Testing Portfolio

[View the latest automated test report](https://jhrahman.github.io/postgresql-database-testing/)

![PostgreSQL](https://img.shields.io/badge/database-PostgreSQL-336791?logo=postgresql&logoColor=white)
![Testing](https://img.shields.io/badge/testing-SQL%20validation-2f855a)

## Project Overview

This repository is a practical database testing portfolio project built with PostgreSQL. It models a small e-commerce system and uses SQL validation queries to check whether the stored data is accurate, complete, consistent, and aligned with defined business rules.

The project demonstrates how a database tester can validate both the structure and the quality of relational data without relying only on application-level tests.

## What This Project Demonstrates

- Designing and understanding relationships between customers, products, orders, and payments
- Validating foreign-key relationships and referential integrity
- Checking calculated values such as order totals
- Reconciling payment amounts against order totals
- Detecting duplicate customer emails and duplicate order combinations
- Verifying payment rules for completed orders
- Writing SQL checks with clear expected outcomes
- Investigating failed validations by reviewing returned rows

## Database Model

The sample database contains four related tables:

| Table | Purpose | Key relationships |
| --- | --- | --- |
| `customers` | Customer identity, contact, location, and status | Referenced by `orders.customer_id` |
| `products` | Product catalogue, prices, and stock quantities | Referenced by `orders.product_id` |
| `orders` | Customer purchases and order totals | References `customers` and `products` |
| `payments` | Payment records and payment status | References `orders` |

The supplied dataset contains 10 customers, 10 products, 18 orders, and 18 payments. It includes completed, pending, and cancelled orders so that the validation queries cover more than one business scenario.

## Test Coverage

The test cases are documented in [`test-cases/database-test-cases.md`](test-cases/database-test-cases.md) and implemented in the SQL files under [`tests/`](tests/).

| Test IDs | Area | Validation |
| --- | --- | --- |
| DB-001 to DB-002 | Data validation | Verify order details and calculate the expected order total |
| DB-003 to DB-004 | Business rules | Find incorrect totals and completed orders with unpaid payments |
| DB-005 to DB-007 | Referential integrity | Find orders or payments with missing parent records |
| DB-008 to DB-009 | Duplicate data | Find duplicate customer emails and duplicate order combinations |
| DB-010 to DB-011 | Data reconciliation | Compare payment amounts with order totals and find completed orders without payments |

### Pass Criteria

Most checks are exception queries: a result set with **zero rows means no violation was found**. DB-001 and DB-002 are retrieval checks and should return the expected values for order `1010`:

- Customer: Tanvir Hasan
- Product: Wireless Mouse
- Quantity: 3
- Order total: `75.00`
- Expected calculation: `25.00 x 3 = 75.00`
- Status: completed

Unexpected rows should be treated as failed validations and investigated against the relevant business rule.

## Repository Structure

```text
.
├── databases/
│   ├── schema.sql       # Tables, keys, and foreign-key constraints
│   └── test_data.sql    # Repeatable sample dataset
├── test-cases/
│   └── database-test-cases.md  # Test objectives and expected results
├── tests/
│   ├── business-rules.sql
│   ├── data-reconciliation.sql
│   ├── data-validation.sql
│   ├── duplicate-data.sql
│   ├── referential-integrity.sql
│   ├── automated-assertions.sql
│   └── scenario-report.sql
├── .github/
│   └── workflows/
│       └── database-tests.yml
├── .env.example          # Local database configuration template
└── README.md
```

## Run the Tests Locally

### Prerequisites

- PostgreSQL 13 or later
- The `psql` command-line client available on your `PATH`
- Permission to create a local database
- A local `.env` file created from `.env.example`

The SQL is standard PostgreSQL and does not require an application server or external service.

### Configure local credentials

Create a local environment file. It is ignored by Git and should never be committed:

```bash
cp .env.example .env
```

Update `PGUSER` and `PGPASSWORD` in `.env` for your local PostgreSQL installation, then load the variables into your shell before running the commands below:

```bash
set -a
source .env
set +a
```

### 1. Create a test database

```bash
createdb "$PGDATABASE"
```

If the database already exists and you want a clean run, recreate it or use a different database name. The schema script drops and recreates the project tables, while the seed script inserts the sample records.

### 2. Load the schema and test data

Run these commands from the repository root:

```bash
psql -f databases/schema.sql
psql -f databases/test_data.sql
```

### 3. Execute the validation suites

Run each suite individually so the output remains easy to trace to a test area:

```bash
psql --set ON_ERROR_STOP=1 --pset pager=off -f tests/data-validation.sql
psql --set ON_ERROR_STOP=1 --pset pager=off -f tests/business-rules.sql
psql --set ON_ERROR_STOP=1 --pset pager=off -f tests/referential-integrity.sql
psql --set ON_ERROR_STOP=1 --pset pager=off -f tests/duplicate-data.sql
psql --set ON_ERROR_STOP=1 --pset pager=off -f tests/data-reconciliation.sql
psql --set ON_ERROR_STOP=1 --pset pager=off -f tests/automated-assertions.sql
```

Or run every test file with one shell loop:

```bash
for file in tests/*.sql; do
  echo "Running $file"
  psql --set ON_ERROR_STOP=1 --pset pager=off -d postgresql_database_testing -f "$file" || exit 1
done
```

### 4. Review the results

- DB-001 and DB-002 should return the expected order `1010` data.
- DB-003 through DB-011 should return zero rows for the supplied clean dataset.
- Any returned exception row identifies the record that needs investigation.
- `ON_ERROR_STOP=1` makes `psql` stop immediately if a SQL or connection error occurs.

## Test Execution Approach

Each test follows a simple, repeatable workflow:

1. Start with a known schema and controlled test data.
2. Execute the SQL validation query.
3. Compare the result with the stated expected outcome.
4. Record and investigate any unexpected rows.
5. Reset the database before rerunning tests when data has been changed.

This project uses query-result validation to make each check transparent and easy to audit directly in `psql`. Together, the schema, controlled dataset, documented test cases, and validation suites provide a complete demonstration of relational database testing fundamentals.

## Continuous Integration

GitHub Actions runs the database tests automatically on every push, pull request, and manual workflow dispatch. The workflow starts a PostgreSQL 16 service, loads the schema and test data, runs the diagnostic SQL suites, and executes [`tests/automated-assertions.sql`](tests/automated-assertions.sql).

The workflow reads `POSTGRES_USER` and `POSTGRES_PASSWORD` from GitHub repository secrets. Configure these under **Settings > Secrets and variables > Actions > New repository secret**. The required secret names are `POSTGRES_USER` and `POSTGRES_PASSWORD`. No database password is stored in the repository.

The diagnostic queries make failures easy to investigate by showing the affected records. The automated assertion suite raises a PostgreSQL error when an expected result is not met, causing the GitHub Actions job to fail.

The workflow also generates a responsive HTML report with an explicit result for every scenario from DB-001 through DB-011. Each scenario displays its category, title, expected outcome, observed result, and a clear `PASS` or `FAIL` badge. The report includes run metadata and assertion output, and is uploaded as a GitHub Actions artifact for every run. For pushes and manual runs, it is additionally published to GitHub Pages; pull requests still receive the downloadable artifact without deploying a public Pages version.

To enable the Pages deployment, set the repository's **Settings > Pages > Source** to **GitHub Actions**. The report link at the top of this README points to the published report.