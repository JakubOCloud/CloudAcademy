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
    """Load JSON file."""
    with open(file_path, "r") as file:
        return json.load(file)


def main():
    parser = argparse.ArgumentParser(description="Drift & Policy Engine")

    parser.add_argument("--desired", required=True)
    parser.add_argument("--actual", required=True)
    parser.add_argument("--policies", required=True)

    args = parser.parse_args()

    desired = load_json(args.desired)
    actual = load_json(args.actual)
    policies = load_json(args.policies)

    print("Desired resources loaded:")
    print(desired)

    print("\nActual resources loaded:")
    print(actual)

    print("\nPolicies loaded:")
    print(policies)


if __name__ == "__main__":
    main()