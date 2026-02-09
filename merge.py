import csv
from pathlib import Path

RESULTS_DIR = Path("results")
OUTPUT_CSV = "merged_city_scores.csv"

rows = []

for csv_path in RESULTS_DIR.glob("*/*/*/*/neighborhood_overall_scores.csv"):
    # Example path:
    # results/united states/wisconsin/sauk city/26.02/neighborhood_overall_scores.csv
    parts = csv_path.parts

    country = parts[-5]
    state = parts[-4]
    city = parts[-3]

    metrics = {}

    with csv_path.open() as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 3:
                continue

            key = row[1]
            value = row[3] if row[3] else row[2]

            if key in {
                "overall_score",
                "weighted_overall_score",
                "population_total",
            }:
                metrics[key] = value

    # Skip incomplete rows
    if len(metrics) != 3:
        print(f"⚠️  Missing data in {csv_path}")
        continue

    rows.append(
        {
            "city_state": f"{city}-{state}".lower(),
            "overall_score": metrics["overall_score"],
            "weighted_overall_score": metrics["weighted_overall_score"],
            "population_total": metrics["population_total"],
        }
    )

# Write merged CSV
with open(OUTPUT_CSV, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(
        [
            "city-state",
            "overall_score",
            "weighted_overall_score",
            "population_total",
        ]
    )
    for r in sorted(rows, key=lambda x: x["city_state"]):
        writer.writerow(
            [
                r["city_state"],
                r["overall_score"],
                r["weighted_overall_score"],
                r["population_total"],
            ]
        )

print(f"✅ Wrote {len(rows)} rows to {OUTPUT_CSV}")
