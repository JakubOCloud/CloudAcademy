import argparse
import pandas as pd
import os

def load_data(file_path):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File '{file_path}' does not exist.")

    df = pd.read_csv(file_path)

    return df

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

    print(df.head())

if __name__ == "__main__":
    main()