import argparse
import pandas as pd
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

    grouped = df.groupby(["service", "environment"])

    for (service, environment), group in grouped:
        group = group.sort_values("date").copy()

        group["baseline"] = (
            group["cost"]
            .rolling(window=3, min_periods=3)
            .mean()
            .shift(1)
        )

        print("=" * 50)
        print(f"Service: {service}")
        print(f"Environment: {environment}")
        for index, row in group.iterrows():

            baseline = row["baseline"]

            if pd.isna(baseline):
                continue

            increase = ((row["cost"] - baseline) / baseline) * 100
            severity = classify(increase)

        if severity:
            print(
                f"[{severity}] "
                f"{row['date'].date()} | "
                f"service={service} | "
                f"env={environment} | "
                f"cost={row['cost']:.2f} | "
                f"baseline={baseline:.2f} | "
                f"increase={increase:.2f}%"
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

    detect_anomalies(df)

if __name__ == "__main__":
    main()