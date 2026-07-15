# Cloud Cost Anomaly Detector

## Requirements

* Python 3.10+
* pandas

Install dependencies:

```bash
pip install -r requirements.txt
```

---

## Running the Application

Run the application using:

```bash
python cost_anomaly_detector.py --input input/daily_costs_sample_1.csv
```

Detected anomalies are:

* displayed in the console,
* exported to `output/anomalies.json`.

---

## Detection Logic

The application analyzes each **service/environment** pair independently.

For every record:

1. A baseline is calculated using the **average cost of the previous three days**.
2. The current day's cost is compared with this baseline.
3. The percentage increase is calculated.
4. If the increase exceeds the configured threshold, the record is reported as an anomaly.

---

## Assumptions

* The input file is provided in CSV format.
* Invalid or incomplete rows are ignored.
* At least three historical records are required before anomaly detection starts.
* Each service and environment combination is analyzed separately.

---

## Severity Thresholds

| Percentage increase | Severity |
| ------------------: | -------- |
|        25% – 49.99% | INFO     |
|        50% – 99.99% | WARNING  |
|        100% or more | CRITICAL |

---

# Additional Questions

## 1. How did you calculate the baseline cost and why did you choose this method?

The baseline is calculated as the rolling average of the previous three days for each service and environment.

---

## 2. How do you distinguish between a normal fluctuation and a real anomaly?

The current cost is compared with the historical baseline. Small deviations are treated as normal fluctuations, while increases above predefined thresholds are classified as anomalies.

---

## 3. What are the limitations of your detection approach?

* Fixed thresholds may not fit every workload.
* Weekly or seasonal usage patterns are not considered.
* Only sudden daily cost increases are detected.
* The algorithm requires historical data before analysis can begin.

---

## 4. How would you improve this tool if you had access to real cloud billing APIs?

I would integrate the tool with services such as AWS Cost Explorer APIs to automatically retrieve billing data. Additional information such as resource tags, regions, and accounts could also be analyzed.

---

## 5. How would you extend the script to detect long-term cost trends, not only daily spikes?

I would calculate weekly and monthly moving averages or use time-series forecasting methods to identify gradual increases in cloud costs over time.

---

## 6. How could this script be integrated into a broader FinOps or DevOps workflow?

The script could run automatically as a scheduled task using GitHub Actions. Detected anomalies could trigger notifications in Slack or email. 

---

## 7. What types of false positives may appear in this solution, and how would you reduce them?

False positives may occur during planned infrastructure scaling, software deployments, seasonal traffic increases, or scheduled maintenance. They could be reduced by using adaptive thresholds, maintenance schedules, resource tagging, or historical trend analysis.
