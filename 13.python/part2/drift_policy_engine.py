import argparse
import json
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List


@dataclass
class Finding:
    finding_type: str
    resource_type: str
    resource_name: str
    severity: str
    reason: str
    expected: str = ""
    actual: str = ""


def load_json(file_path: str):
    """Load JSON file with error handling."""

    try:
        with open(file_path, "r") as file:
            return json.load(file)

    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {file_path}")

    except json.JSONDecodeError:
        raise ValueError(f"Invalid JSON format in {file_path}")
    
def validate_input(data: dict, name: str):
    """Validate input JSON structure."""

    if not isinstance(data, dict):
        raise ValueError(f"{name} must contain a JSON object.")

    required_sections = ["instances", "security_groups", "buckets"]

    # policies mają inną strukturę
    if name == "Policies":
        return

    for section in required_sections:
        if section not in data:
            raise ValueError(f"{name} is missing '{section}' section.")

        if not isinstance(data[section], list):
            raise ValueError(f"'{section}' must be a list.")

def main():
    parser = argparse.ArgumentParser(description="Drift & Policy Engine")

    parser.add_argument("--desired", required=True)
    parser.add_argument("--actual", required=True)
    parser.add_argument("--policies", required=True)

    args = parser.parse_args()

    try:
        desired = load_json(args.desired)
        actual = load_json(args.actual)
        policies = load_json(args.policies)

        validate_input(desired, "Desired State")
        validate_input(actual, "Actual State")
        validate_input(policies, "Policies")

        print("All input files validated successfully.")

        print("\nDesired resources loaded:")
        print(desired)

        print("\nActual resources loaded:")
        print(actual)

        print("\nPolicies loaded:")
        print(policies)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()