import csv
from pathlib import Path

RESULTS_DIR = Path("results")
OUTPUT_CSV = "merged_city_scores.csv"
HISTORICAL_CSV = "historical_scores.csv"

STATE_ABBREV = {
    "wisconsin": "WI",
    "minnesota": "MN",
    "illinois": "IL",
    "michigan": "MI",
    # add more states later if needed
}

def norm(s: str) -> str:
    return s.strip().lower()

# -----------------------------
# Load historical 2025 scores
# -----------------------------
historical = {}

with open(HISTORICAL_CSV, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row["country"] != "US":
            continue

        city = norm(row["city"])
        state = row["state"]
        score_2025 = row.get("2025", "").strip()

        if not score_2025:
            continue

        historical[(city, state)] = score_2025

# -----------------------------
# Walk results + merge
# -----------------------------
rows = []

for csv_path in RESULTS_DIR.glob("*/*/*/*/neighborhood_overall_scores.csv"):
    parts = csv_path.parts

    state_name = parts[-4]
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

    if len(metrics) != 3:
        print(f"⚠️  Missing metrics in {csv_path}")
        continue

    state_abbrev = STATE_ABBREV.get(norm(state_name))
    old_score = ""

    if state_abbrev:
        old_score = historical.get(
            (norm(city), state_abbrev),
            ""
        )

    rows.append(
        {
            "city_state": f"{city}-{state_name}".lower(),
            "overall_score": metrics["overall_score"],
            "weighted_overall_score": metrics["weighted_overall_score"],
            "population_total": metrics["population_total"],
            "old_score": old_score,
        }
    )

# -----------------------------
# Write final CSV
# -----------------------------
with open(OUTPUT_CSV, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(
        [
            "city-state",
            "overall_score",
            "weighted_overall_score",
            "population_total",
            "old_score",
        ]
    )

    for r in sorted(rows, key=lambda x: x["city_state"]):
        writer.writerow(
            [
                r["city_state"],
                r["overall_score"],
                r["weighted_overall_score"],
                r["population_total"],
                r["old_score"],
            ]
        )

print(f"✅ Wrote {len(rows)} rows to {OUTPUT_CSV}")
