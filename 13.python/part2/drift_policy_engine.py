import argparse
import json
from dataclasses import dataclass, asdict
from typing import List
from collections import Counter

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

        if "rules" not in data:
            raise ValueError("Policies must contain 'rules'.")

        if not isinstance(data["rules"], list):
            raise ValueError("'rules' must be a list.")

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

def detect_security_group_drift(desired_groups, actual_groups):
    """Compare desired and actual security groups."""

    findings = []

    desired_map = {sg["name"]: sg for sg in desired_groups}
    actual_map = {sg["name"]: sg for sg in actual_groups}

    for name in desired_map:
        if name not in actual_map:
            findings.append(
                Finding(
                    finding_type="missing_resource",
                    resource_type="security_group",
                    resource_name=name,
                    severity="HIGH",
                    reason="Security group missing from actual state."
                )
            )

    for name in actual_map:
        if name not in desired_map:
            findings.append(
                Finding(
                    finding_type="unexpected_resource",
                    resource_type="security_group",
                    resource_name=name,
                    severity="LOW",
                    reason="Unexpected security group found."
                )
            )

    for name in desired_map:
        if name in actual_map:

            desired_sg = desired_map[name]
            actual_sg = actual_map[name]

            if desired_sg["ingress"] != actual_sg["ingress"]:

                findings.append(
                    Finding(
                        finding_type="changed_resource",
                        resource_type="security_group",
                        resource_name=name,
                        severity="HIGH",
                        reason="Ingress rules changed.",
                        expected=str(desired_sg["ingress"]),
                        actual=str(actual_sg["ingress"])
                    )
                )

    return findings

def detect_bucket_drift(desired_buckets, actual_buckets):
    """Compare desired and actual buckets."""

    findings = []

    desired_map = {bucket["name"]: bucket for bucket in desired_buckets}
    actual_map = {bucket["name"]: bucket for bucket in actual_buckets}

    for name in desired_map:
        if name not in actual_map:
            findings.append(
                Finding(
                    finding_type="missing_resource",
                    resource_type="bucket",
                    resource_name=name,
                    severity="HIGH",
                    reason="Bucket missing from actual state."
                )
            )

    for name in actual_map:
        if name not in desired_map:
            findings.append(
                Finding(
                    finding_type="unexpected_resource",
                    resource_type="bucket",
                    resource_name=name,
                    severity="LOW",
                    reason="Unexpected bucket found."
                )
            )

    for name in desired_map:
        if name in actual_map:

            desired_bucket = desired_map[name]
            actual_bucket = actual_map[name]

            if desired_bucket["encryption"] != actual_bucket["encryption"]:

                findings.append(
                    Finding(
                        finding_type="changed_resource",
                        resource_type="bucket",
                        resource_name=name,
                        severity="HIGH",
                        reason="Bucket encryption drift detected.",
                        expected=str(desired_bucket["encryption"]),
                        actual=str(actual_bucket["encryption"])
                    )
                )

    return findings

def check_bucket_encryption(actual_buckets):
    findings = []

    for bucket in actual_buckets:

        if not bucket["encryption"]:

            findings.append(
                Finding(
                    finding_type="policy_violation",
                    resource_type="bucket",
                    resource_name=bucket["name"],
                    severity="HIGH",
                    reason="Bucket encryption is disabled.",
                    expected="True",
                    actual="False"
                )
            )

    return findings

def check_required_tags(instances, required_tags):

    findings = []

    for instance in instances:

        tags = instance.get("tags", {})

        for tag in required_tags:

            if tag not in tags:

                findings.append(
                    Finding(
                        finding_type="policy_violation",
                        resource_type="instance",
                        resource_name=instance["name"],
                        severity="MEDIUM",
                        reason=f"Missing required tag: {tag}",
                        expected=tag,
                        actual="Missing"
                    )
                )

    return findings

def check_public_ssh(actual_security_groups):
    findings = []

    for sg in actual_security_groups:

        for rule in sg["ingress"]:

            if rule["port"] == 22 and rule["cidr"] == "0.0.0.0/0":

                findings.append(
                    Finding(
                        finding_type="policy_violation",
                        resource_type="security_group",
                        resource_name=sg["name"],
                        severity="CRITICAL",
                        reason="Public SSH access detected.",
                        expected="Internal network only",
                        actual="0.0.0.0/0"
                    )
                )

    return findings

def check_allowed_instance_types(instances, allowed_types):

    findings = []

    for instance in instances:

        tags = instance.get("tags", {})

        if tags.get("Environment") == "prod":

            if instance["type"] not in allowed_types:

                findings.append(
                    Finding(
                        finding_type="policy_violation",
                        resource_type="instance",
                        resource_name=instance["name"],
                        severity="HIGH",
                        reason="Instance type is not allowed in production.",
                        expected=str(allowed_types),
                        actual=instance["type"]
                    )
                )

    return findings

def validate_policies(actual, policies):

    findings = []

    for rule in policies["rules"]:

        if rule["type"] == "bucket_encryption_required":

            findings.extend(
                check_bucket_encryption(actual["buckets"])
            )

        elif rule["type"] == "deny_public_ssh":

            findings.extend(
                check_public_ssh(actual["security_groups"])
            )

        elif rule["type"] == "required_tags":

            findings.extend(
                check_required_tags(
                    actual["instances"],
                    rule["tags"]
                )
            )

        elif rule["type"] == "allowed_instance_types_prod":

            findings.extend(
                check_allowed_instance_types(
                    actual["instances"],
                    rule["allowed"]
                )
            )

    return findings

def export_findings(findings, filename="findings_report.json"):
    """Export findings to JSON file."""

    with open(filename, "w") as file:
        json.dump(
            [asdict(finding) for finding in findings],
            file,
            indent=4
        )

def print_report(drift_findings, policy_findings, actual):

    all_findings = drift_findings + policy_findings

    total_resources = (
        len(actual["instances"]) +
        len(actual["security_groups"]) +
        len(actual["buckets"])
    )

    severity_count = Counter(
        finding.severity for finding in all_findings
    )

    print("\n" + "=" * 50)
    print(" Drift & Policy Compliance Report")
    print("=" * 50)

    print(f"\nResources analyzed : {total_resources}")
    print(f"Drift findings     : {len(drift_findings)}")
    print(f"Policy violations  : {len(policy_findings)}")

    print("\nSeverity Breakdown")

    for severity in ["LOW", "MEDIUM", "HIGH", "CRITICAL"]:
        print(f"{severity:<10}: {severity_count.get(severity,0)}")

    print("\nDetailed Findings")
    print("-" * 50)

    for finding in all_findings:

        print(f"[{finding.severity}] {finding.finding_type}")
        print(f"Resource Type : {finding.resource_type}")
        print(f"Resource Name : {finding.resource_name}")
        print(f"Reason        : {finding.reason}")

        if finding.expected:
            print(f"Expected      : {finding.expected}")

        if finding.actual:
            print(f"Actual        : {finding.actual}")

        print("-" * 50)

    print("\nSummary")

    print(f"Total Findings     : {len(all_findings)}")
    print(f"Drift Findings     : {len(drift_findings)}")
    print(f"Policy Violations  : {len(policy_findings)}")

    print("\nTop Critical Issues")

    critical = [
        finding
        for finding in all_findings
        if finding.severity == "CRITICAL"
    ]

    if critical:

        for finding in critical:
            print(f"- {finding.reason} ({finding.resource_name})")

    else:
        print("None")

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

        instance_findings = detect_instance_drift(
            desired["instances"],
            actual["instances"]
        )

        sg_findings = detect_security_group_drift(
            desired["security_groups"],
            actual["security_groups"]
        )

        bucket_findings = detect_bucket_drift(
            desired["buckets"],
            actual["buckets"]
        )

        drift_findings = (
            instance_findings +
            sg_findings +
            bucket_findings
        )

        policy_findings = validate_policies(actual, policies)

        all_findings = drift_findings + policy_findings

        export_findings(all_findings)

        print_report(
            drift_findings,
            policy_findings,
            actual
        )

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()