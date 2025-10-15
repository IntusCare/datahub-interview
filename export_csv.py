import sqlite3
import csv
import sys

if len(sys.argv) != 3:
    print("Usage: python export_csv.py <firstname> <lastname>")
    print("Example: python export_csv.py john doe")
    sys.exit(1)

firstname = sys.argv[1].lower()
lastname = sys.argv[2].lower()
filename = f"{firstname}_{lastname}.csv"

conn = sqlite3.connect('main_final.db')
cursor = conn.cursor()

cursor.execute('SELECT * FROM patient_encounter_summary')
columns = [description[0] for description in cursor.description]
rows = cursor.fetchall()

with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(columns)
    writer.writerows(rows)

print(f"Exported {len(rows)} rows to {filename}")
print(f"Columns: {', '.join(columns)}")

# Close connection
conn.close()
