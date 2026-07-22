# Drift & Policy Engine

## Overview

Drift & Policy Engine is a Python script that compares the expected infrastructure state with the current infrastructure state. It also validates the current infrastructure against internal platform policies and generates a compliance report.

The tool helps detect:

* configuration drift,
* policy violations,
* security issues,
* missing or unexpected resources.

---

## Requirements

* Python 3.10 or newer

No external libraries are required.

---

## Project Structure

```
drift-policy-engine/
│
├── drift_policy_engine.py
├── desired_state.json
├── actual_state.json
├── policies.json
├── findings_report.json
├── README.md
└── .gitignore
```

---

## How to Run

Run the script from the project directory:

```bash
python drift_policy_engine.py --desired desired_state.json --actual actual_state.json --policies policies.json
```

---

## How Drift Is Detected

The script compares resources from the desired state with resources from the actual state.

Resources are matched using their **name**, not their position in the JSON file.

The following drift types are detected:

* **missing_resource** – resource exists in the desired state but is missing in the actual state.
* **unexpected_resource** – resource exists in the actual state but should not exist.
* **changed_resource** – resource exists in both files but important configuration values are different.

Compared fields:

* **Instances:** instance type
* **Security Groups:** ingress rules
* **Buckets:** encryption status

---

## Policy Validation

The script validates the actual infrastructure using rules defined in `policies.json`.

---

## Severity Levels

Each finding receives one of four severity levels:

* **LOW** – unexpected resources.
* **MEDIUM** – missing required tags.
* **HIGH** – configuration drift or disabled bucket encryption.
* **CRITICAL** – public SSH access detected.

---

## Output

The script produces:

1. A compliance report printed to the console.
2. A JSON file (`findings_report.json`) containing all detected findings.

---

# Additional Questions

## 1. How do you distinguish between drift and policy violation in your implementation?

Drift detection compares the desired infrastructure state with the actual infrastructure state. It identifies resources that are missing, unexpected, or have different configuration values.

Policy validation checks only the actual infrastructure against the rules defined in `policies.json`.

---

## 2. Which fields should be compared for each resource type, and why?

The comparison focuses only on the most important configuration fields.

* **Instances:** instance type, because changing the instance type changes the compute resources.
* **Security Groups:** ingress rules, because they define network access and security.
* **Buckets:** encryption status, because encryption is an important security requirement.

---

## 3. How did you assign severity levels to findings?

Severity levels are assigned based on the potential impact of each finding.

* **LOW** – unexpected resources.
* **MEDIUM** – missing required tags.
* **HIGH** – configuration drift and disabled bucket encryption.
* **CRITICAL** – public SSH access from `0.0.0.0/0`.

The classification is based on how much the issue could affect infrastructure consistency or security.

---

## 4. What are the limitations of your current comparison logic?

The current implementation has several limitations:

* It supports only instances, security groups, and buckets.
* It compares only selected configuration fields.
* It assumes that resource names are unique.
* It does not detect more complex configuration differences.

---

## 5. How would you extend the tool to support additional resource types such as IAM roles, databases, or Kubernetes resources?

The tool can be extended by adding new comparison and policy validation functions.

Examples:

* **IAM roles** – compare attached policies and permissions.
* **Databases** – compare engine version, storage size, encryption, and backup settings.
* **Kubernetes resources** – compare Deployments, Services, ConfigMaps, resource limits, replicas, or container images.

Each new resource type would follow the same approach used for the existing resources.

---

## 6. How would you integrate this script into a CI/CD or governance workflow?

The script could be executed automatically during a CI/CD pipeline before infrastructure changes are applied.

It could also run on a schedule to compare the current infrastructure with the expected configuration and generate compliance reports.

If any critical findings are detected, the pipeline could fail or send a notification to the engineering team.

---

## 7. How could this tool help prevent configuration drift in a real organization?

The tool helps identify manual changes that differ from the expected infrastructure configuration.

By running regularly, it allows engineers to detect configuration drift early, improve security, enforce internal policies, and keep infrastructure consistent across environments.
