#!/usr/bin/env python3
"""
Grade the DBT interview exercise by comparing candidate results with answer key.
"""

import sqlite3
import csv
import sys
from pathlib import Path
from typing import List, Tuple, Dict


def export_to_csv(db_path: str, table_name: str, output_csv: str) -> List[List]:
    """Export a SQLite table to CSV and return the data."""
    if not Path(db_path).exists():
        print(f"Error: Database not found: {db_path}")
        sys.exit(1)

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get all data from table
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()

    # Get column names
    column_names = [description[0] for description in cursor.description]

    # Write to CSV
    with open(output_csv, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(column_names)
        writer.writerows(rows)

    conn.close()

    print(f"✓ Exported {len(rows)} rows from {db_path} to {output_csv}")
    return [column_names] + rows


def compare_results(candidate_data: List[List], answer_data: List[List]) -> Dict:
    """Compare candidate results with answer key cell by cell."""

    # Check if both have same dimensions
    if len(candidate_data) != len(answer_data):
        print(f"⚠️  Warning: Row count mismatch!")
        print(f"   Candidate: {len(candidate_data) - 1} rows")
        print(f"   Answer:    {len(answer_data) - 1} rows")

    if len(candidate_data[0]) != len(answer_data[0]):
        print(f"⚠️  Warning: Column count mismatch!")
        print(f"   Candidate: {len(candidate_data[0])} columns")
        print(f"   Answer:    {len(answer_data[0])} columns")
        return {"error": "Column count mismatch"}

    # Headers
    headers = candidate_data[0]

    # Columns to exclude from grading (timestamps, etc.)
    exclude_columns = {'created_at', 'updated_at', '_airbyte_extracted_at', '_airbyte_raw_id'}

    # Compare data rows
    total_cells = 0
    correct_cells = 0
    errors = []

    max_rows = min(len(candidate_data), len(answer_data))

    for row_idx in range(1, max_rows):  # Skip header row
        candidate_row = candidate_data[row_idx]
        answer_row = answer_data[row_idx]

        for col_idx, (candidate_val, answer_val) in enumerate(zip(candidate_row, answer_row)):
            column_name = headers[col_idx] if col_idx < len(headers) else f"col_{col_idx}"

            # Skip excluded columns (timestamps, etc.)
            if column_name in exclude_columns:
                continue

            total_cells += 1

            # Normalize values for comparison (handle None, strings, numbers)
            candidate_normalized = str(candidate_val).strip() if candidate_val is not None else ""
            answer_normalized = str(answer_val).strip() if answer_val is not None else ""

            if candidate_normalized == answer_normalized:
                correct_cells += 1
            else:
                # Record error details
                errors.append({
                    "row": row_idx,
                    "column": column_name,
                    "candidate_value": candidate_val,
                    "expected_value": answer_val
                })

    return {
        "total_cells": total_cells,
        "correct_cells": correct_cells,
        "incorrect_cells": total_cells - correct_cells,
        "errors": errors
    }


def print_grade_report(comparison: Dict):
    """Print a formatted grade report."""

    if "error" in comparison:
        print(f"\n❌ ERROR: {comparison['error']}")
        return

    total = comparison["total_cells"]
    correct = comparison["correct_cells"]
    incorrect = comparison["incorrect_cells"]
    percentage = (correct / total * 100) if total > 0 else 0

    print("\n" + "="*70)
    print("GRADE REPORT")
    print("="*70)
    print(f"\nTotal cells compared:    {total}")
    print(f"Correct cells:           {correct}")
    print(f"Incorrect cells:         {incorrect}")
    print(f"\n{'='*70}")
    print(f"FINAL GRADE: {percentage:.2f}%")
    print(f"{'='*70}\n")

    # Print details of errors if any
    if incorrect > 0:
        print(f"\n⚠️  Found {incorrect} incorrect cell(s):\n")

        # Limit error display to first 20
        errors_to_show = comparison["errors"][:20]

        for i, error in enumerate(errors_to_show, 1):
            print(f"{i}. Row {error['row']}, Column '{error['column']}':")
            print(f"   Candidate: {error['candidate_value']}")
            print(f"   Expected:  {error['expected_value']}")
            print()

        if len(comparison["errors"]) > 20:
            print(f"   ... and {len(comparison['errors']) - 20} more errors\n")
    else:
        print("✓ All cells match perfectly! 🎉\n")


def main():
    """Main grading function."""

    print("\n" + "="*70)
    print("DBT INTERVIEW EXERCISE - AUTOMATED GRADING")
    print("="*70 + "\n")

    # Database paths
    candidate_db = "main_final.db"
    answer_db_staged = "main_final.db"  # Will be created when switching to answers

    # Table to compare
    table_name = "patient_encounter_summary"

    # Check if databases exist
    if not Path(candidate_db).exists():
        print(f"❌ Error: Candidate database not found: {candidate_db}")
        print("   Please run 'dbt run' first to generate the candidate's results.")
        sys.exit(1)

    # Step 1: Export candidate results
    print("Step 1: Exporting candidate results...")
    candidate_csv = "candidate_results.csv"
    candidate_data = export_to_csv(candidate_db, table_name, candidate_csv)

    # Step 2: Switch to answers and run DBT
    print("\nStep 2: Generating answer key results...")
    print("   (This requires switching model-paths to 'answers' in dbt_project.yml)")

    import subprocess
    import os

    # Read current dbt_project.yml
    with open('dbt_project.yml', 'r') as f:
        original_config = f.read()

    # Modify to use answers
    modified_config = original_config.replace(
        'model-paths: ["models"]',
        '# model-paths: ["models"]'
    ).replace(
        '# model-paths: ["answers"]',
        'model-paths: ["answers"]'
    )

    # Write modified config
    with open('dbt_project.yml', 'w') as f:
        f.write(modified_config)

    try:
        # Set environment variable
        env = os.environ.copy()
        env['DBT_PROFILES_DIR'] = os.getcwd()

        # Clean and run with answers
        print("   Cleaning previous results...")
        subprocess.run(['rm', '-f'] + list(Path('.').glob('*.db')),
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        print("   Running dbt seed...")
        result = subprocess.run(['dbt', 'seed'], env=env,
                              capture_output=True, text=True, timeout=60)
        if result.returncode != 0:
            print(f"   Error running dbt seed:")
            print(result.stdout)
            print(result.stderr)
            raise RuntimeError("dbt seed failed")

        print("   Running dbt run with answer key...")
        result = subprocess.run(['dbt', 'run'], env=env,
                              capture_output=True, text=True, timeout=60)
        if result.returncode != 0:
            print(f"   Error running dbt run:")
            print(result.stdout)
            print(result.stderr)
            raise RuntimeError("dbt run failed")

        # Step 3: Export answer key results
        print("\nStep 3: Exporting answer key results...")
        answer_csv = "answer_key_results.csv"
        answer_data = export_to_csv(answer_db_staged, table_name, answer_csv)

        # Step 4: Restore original config
        with open('dbt_project.yml', 'w') as f:
            f.write(original_config)

        # Step 5: Re-run with candidate code
        print("\nStep 4: Restoring candidate environment...")
        subprocess.run(['rm', '-f'] + list(Path('.').glob('*.db')),
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run(['dbt', 'seed'], env=env,
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run(['dbt', 'run'], env=env,
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        print("✓ Candidate environment restored")

        # Step 6: Compare results
        print("\nStep 5: Comparing results...\n")
        comparison = compare_results(candidate_data, answer_data)

        # Step 7: Print grade report
        print_grade_report(comparison)

        # Save detailed report
        with open('grade_report.txt', 'w') as f:
            f.write("DBT INTERVIEW EXERCISE - GRADE REPORT\n")
            f.write("="*70 + "\n\n")
            f.write(f"Total cells compared:    {comparison['total_cells']}\n")
            f.write(f"Correct cells:           {comparison['correct_cells']}\n")
            f.write(f"Incorrect cells:         {comparison['incorrect_cells']}\n")
            percentage = (comparison['correct_cells'] / comparison['total_cells'] * 100)
            f.write(f"\nFINAL GRADE: {percentage:.2f}%\n\n")

            if comparison['incorrect_cells'] > 0:
                f.write("\nDETAILED ERRORS:\n")
                f.write("-"*70 + "\n\n")
                for error in comparison['errors']:
                    f.write(f"Row {error['row']}, Column '{error['column']}':\n")
                    f.write(f"  Candidate: {error['candidate_value']}\n")
                    f.write(f"  Expected:  {error['expected_value']}\n\n")

        print("✓ Detailed report saved to: grade_report.txt")
        print("✓ Candidate results saved to: candidate_results.csv")
        print("✓ Answer key saved to: answer_key_results.csv")

    finally:
        # Always restore original config
        with open('dbt_project.yml', 'w') as f:
            f.write(original_config)


if __name__ == "__main__":
    main()
