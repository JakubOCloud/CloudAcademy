import argparse
import pandas as pd
import json
import os

def load_data(file_path):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File '{file_path}' does not exist.")

    df = pd.read_csv(file_path)

    required_columns = {"date", "service", "environment", "cost"}

    if not required_columns.issubset(df.columns):
        missing = required_columns - set(df.columns)
        raise ValueError(f"Missing required columns: {missing}")
    
    rows_before = len(df)
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df["cost"] = pd.to_numeric(df["cost"], errors="coerce")

    df = df.dropna(subset=["date", "service", "environment", "cost"])

    invalid_rows = rows_before - len(df)

    if invalid_rows > 0:
        print(f"Skipped {invalid_rows} invalid rows.")

    df = df.sort_values("date")

    return df

def classify(increase):

    if increase >= 100:
        return "CRITICAL"

    elif increase >= 50:
        return "WARNING"

    elif increase >= 25:
        return "INFO"

    return None

def detect_anomalies(df):
    anomalies = []

    grouped = df.groupby(["service", "environment"])

    for (service, environment), group in grouped:
        group = group.sort_values("date").copy()

        group["baseline"] = (
            group["cost"]
            .rolling(window=3, min_periods=3)
            .mean()
            .shift(1)
        )

        for index, row in group.iterrows():

            baseline = row["baseline"]

            if pd.isna(baseline):
                continue

            increase = ((row["cost"] - baseline) / baseline) * 100
            severity = classify(increase)

        if severity:

            anomalies.append({
                "date": row["date"].strftime("%Y-%m-%d"),
                "service": service,
                "environment": environment,
                "actual_cost": round(row["cost"], 2),
                "baseline_cost": round(baseline, 2),
                "increase_percent": round(increase, 2),
                "severity": severity,
                "reason": "Cost exceeded anomaly threshold"
            })
    return anomalies

def print_report(anomalies):

    if not anomalies:
        print("No anomalies detected.")
        return

    print("\nDetected anomalies:\n")

    for anomaly in anomalies:

        print(
            f"[{anomaly['severity']}] "
            f"{anomaly['date']} | "
            f"service={anomaly['service']} | "
            f"env={anomaly['environment']} | "
            f"cost={anomaly['actual_cost']:.2f} | "
            f"baseline={anomaly['baseline_cost']:.2f} | "
            f"increase={anomaly['increase_percent']:.2f}% | "
            f"reason={anomaly['reason']}"
        )

def export_json(anomalies):

    os.makedirs("output", exist_ok=True)

    with open("output/anomalies.json", "w") as file:
        json.dump(anomalies, file, indent=4)

    print("\nJSON report saved to output/anomalies.json")

def print_summary(df, anomalies):

    print("\nSummary")
    print("-" * 40)

    print(f"Records analyzed : {len(df)}")
    print(f"Anomalies found  : {len(anomalies)}")

    severity_count = {}

    for anomaly in anomalies:

        severity = anomaly["severity"]

        severity_count[severity] = severity_count.get(severity, 0) + 1

    print("\nAnomalies by severity:")

    for severity in ["INFO", "WARNING", "CRITICAL"]:

        print(f"{severity:10}: {severity_count.get(severity, 0)}")

    print("\nTop 3 anomalies:")

    top3 = sorted(
        anomalies,
        key=lambda anomaly: anomaly["increase_percent"],
        reverse=True
    )[:3]

    for anomaly in top3:

        print(
            f"{anomaly['service']} "
            f"({anomaly['environment']}) - "
            f"{anomaly['increase_percent']:.2f}%"
        )

def main():
    parser = argparse.ArgumentParser(
        description="Cloud Cost Anomaly Detector"
    )

    parser.add_argument(
        "--input",
        required=True,
        help="Path to CSV file"
    )

    args = parser.parse_args()

    df = load_data(args.input)

    anomalies = detect_anomalies(df)

    print_report(anomalies)
    export_json(anomalies)
    print_summary(df, anomalies)

if __name__ == "__main__":
    main()