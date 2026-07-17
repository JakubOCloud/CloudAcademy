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

    if name == "Policies":
        return

    for section in required_sections:
        if section not in data:
            raise ValueError(f"{name} is missing '{section}' section.")

        if not isinstance(data[section], list):
            raise ValueError(f"'{section}' must be a list.")
        
def detect_instance_drift(desired_instances, actual_instances):
    """Compare desired and actual instances."""

    findings = []

    desired_map = {instance["name"]: instance for instance in desired_instances}
    actual_map = {instance["name"]: instance for instance in actual_instances}

    for name in desired_map:
        if name not in actual_map:
            findings.append(
                Finding(
                    finding_type="missing_resource",
                    resource_type="instance",
                    resource_name=name,
                    severity="HIGH",
                    reason="Instance missing from actual state."
                )
            )

    for name in actual_map:
        if name not in desired_map:
            findings.append(
                Finding(
                    finding_type="unexpected_resource",
                    resource_type="instance",
                    resource_name=name,
                    severity="LOW",
                    reason="Unexpected instance found."
                )
            )

    for name in desired_map:
        if name in actual_map:

            desired_instance = desired_map[name]
            actual_instance = actual_map[name]

            if desired_instance["type"] != actual_instance["type"]:

                findings.append(
                    Finding(
                        finding_type="changed_resource",
                        resource_type="instance",
                        resource_name=name,
                        severity="HIGH",
                        reason="Instance type drift detected.",
                        expected=desired_instance["type"],
                        actual=actual_instance["type"]
                    )
                )

    return findings

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

        instance_findings = detect_instance_drift(
        desired["instances"],
        actual["instances"]
        )

        print("\nInstance Drift Findings:\n")

        for finding in instance_findings:
            print(finding)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()