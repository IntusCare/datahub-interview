# DataHub Interview Exercise

A technical exercise for data engineering candidates on the DataHub team.

## Objective

To assess a candidate's knowledge and skills when using technologies we use on the DataHub team. We want to get a sense for:

* Ability to code SQL using CTEs (Common Table Expressions)
* Ability to understand our transformation pipeline's structure and stages
* Healthcare data domain familiarity
* DBT (Data Build Tool) proficiency
* Git workflow and version control practices

## Overview

This exercise simulates our real-world data transformation pipeline. You'll work with healthcare data (patients, encounters, diagnoses) and transform it through multiple stages using DBT and SQL, following the same patterns we use in production.

**Time Limit:** 1 hour

**Note:** Focus on completing the staged layer first, then intermediate, then final if time permits. Quality over quantity - we'd rather see one layer done well than all layers done poorly.

---

## Setup Instructions

### Prerequisites

- Python 3.8 or higher
- Git
- A text editor or IDE of your choice

### 1. Clone the Repository and Create Your Branch

```bash
git clone <repository-url>
cd datahub-interview

# Create a branch with your name (use underscores, no spaces)
git checkout -b firstname_lastname
```

**Example:** If your name is Jane Doe, use: `git checkout -b jane_doe`

### 2. Create a Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure DBT Profile

```bash
# Copy the profiles.yml to your home directory
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml

# Or set the DBT_PROFILES_DIR environment variable
export DBT_PROFILES_DIR=$(pwd)
```

### 5. Verify Setup

```bash
dbt debug
```

You should see "All checks passed!"

---

## Data Pipeline Architecture

Our transformation pipeline follows a **four-stage architecture**:

```
Seeds (CSV files)
    ↓
Raw Layer (ephemeral)
    ↓
Staged Layer (cleaned & standardized)
    ↓
Intermediate Layer (joined & business logic)
    ↓
Final Layer (analytics-ready aggregations)
```

### Naming Conventions

- **Raw models**: `raw__<entity>.sql` (materialized as ephemeral, note the double underscore)
- **Staged models**: `stg__<entity>.sql` (materialized as tables)
- **Intermediate models**: `int__<entity>.sql` (materialized as tables)
- **Final models**: `<entity>.sql` (materialized as tables, no prefix)

---

## Exercise Tasks

You will complete the transformation logic for **three layers**: staged, intermediate, and final.

**Key Requirements:**
- Handle data quality issues (NULLs, formatting inconsistencies)
- Make the correct joins, being aware of where the one-to-many relationships are between data
- Produce the final table of patieant-centered encounter and diagnostic data.

**Preferred Approaches**
- Use CTEs to structure your queries
- Demonstrate proper use of the macro that are in the macros directory in your queries

### Task 1: Staged Layer (Data Cleaning)

Complete the following models in `models/staged/`:

#### `stg_patient.sql`
- Clean and standardize patient demographics
- Ensure that all phone numbers are formatted as XXX-XXX-XXXX
- Handle NULL email addresses
- Cast date fields appropriately
- Add timestamps



#### `stg_encounter.sql`
- Clean and standardize encounter data
- Filter for completed encounters only
- Standardize encounter types
- Cast date fields appropriately

#### `stg_diagnosis.sql`
- Clean and standardize diagnosis data
- Uppercase and trim ICD-10 codes
- Cast date and boolean fields appropriately

### Task 2: Intermediate Layer (Business Logic)

Complete `models/intermediate/int__patient_encounter.sql`:

- Join patient, encounter, and diagnosis data
- Calculate patient age at time of encounter
- Identify primary diagnoses
- Count total diagnoses per encounter
- Flag encounters with chronic conditions
  - Chronic conditions for this exercise: `I10`, `E11.9`, `E11.65`, `J44.9`, `J44.1`, `I50.9`

**Key Requirements:**
- Use multiple CTEs for logical organization
- Demonstrate proper join techniques
- Apply business logic calculations

### Task 3: Final Layer (Analytics Aggregations)

Complete `models/final/patient_encounter_summary.sql`:

- Create patient-level summary statistics
- Aggregate encounter counts, diagnosis counts
- Calculate temporal metrics (first/last encounter dates)
- Identify most common encounter types
- Count emergency visits

**Key Requirements:**
- Use CTEs for complex aggregations
- Demonstrate window functions or grouping techniques
- Create analytics-ready output

---

## Running Your Transformations

### Load Seed Data

```bash
dbt seed
```

### Run All Models

```bash
dbt run
```

### Run Specific Models

```bash
# Run staged layer only
dbt run --select staged.*

# Run a specific model
dbt run --select stg_patient
```

### Test Your Models

```bash
dbt test
```

---

## Expected Deliverables

When you have completed the exercise, follow these steps:

### 1. Export Your Results

Generate a CSV file from your final database with your name:

```bash
# Replace firstname and lastname with your actual name (lowercase, underscores)
sqlite3 main_final.db ".mode csv" ".headers on" \
  ".output firstname_lastname.csv" \
  "SELECT * FROM patient_encounter_summary;" \
  ".quit"
```

**Example:** For Jane Doe, the file should be named `jane_doe.csv`

### 2. Commit Your Work

```bash
# Add your models and CSV file
git add models/staged/ models/intermediate/ models/final/
git add firstname_lastname.csv

# Commit with a meaningful message
git commit -m "Complete DBT interview exercise - [Your Name]"
```

### 3. Push Your Branch

```bash
# Push your branch to remote
git push origin <firstname>_<lastname>
```

### 4. Open a Pull Request

Go to the [Datahub-Interview repo](https://github.com/IntusCare/datahub-interview) and open a pull request.

### 4. What We're Looking For

- **Completed SQL Models**: All TODOs in the staged, intermediate, and final models implemented
- **Clean, Readable SQL**: Proper CTE usage and clear structure
- **Working Pipeline**: All models run successfully with `dbt run` (no errors)
- **CSV Output**: Your results exported as `<firstname>_<lastname>.csv`
- **Git History**: Meaningful commit messages showing your work
- **PR Interaction**: How you handle comments on your pull request


## Tips & Hints

### SQLite-Specific Functions

- **Date calculations**: Use `julianday()` for date arithmetic
  ```sql
  -- Calculate age
  (julianday('now') - julianday(dob)) / 365.25
  ```

- **String functions**: `substr()`, `replace()`, `trim()`, `upper()`, `lower()`

- **NULL handling**: `coalesce()`, `ifnull()`

### Debugging

```bash
# View compiled SQL
dbt compile

# Run with debug logging
dbt run --debug

# View logs
cat logs/dbt.log
```

### Common Issues

- **Phone number cleaning**: Remove all non-numeric characters before formatting
- **Date casting**: SQLite stores dates as text, cast appropriately
- **Boolean handling**: SQLite uses 0/1 for booleans
- **CTEs**: Remember to reference them in your final SELECT

---

## Questions?

If you have questions during the exercise, please reach out to your interview coordinator.

Good luck! 
