# Self-Healing Toolkit Lab — Student Version

This package provides the lab environment for the **Bash – Self-Healing Toolkit** task.

## Important

The self-healing script is **not included** in this package.

Your task is to implement:

```bash
self-heal.sh
```

based on the assignment requirements.

## Included files

- `app.py` — fake HTTP service exposing `/health`
- `payment-api.service` — `systemd` unit
- `setup_lab.sh` — installs the lab locally
- `failure_scenarios.sh` — triggers test failures

## Requirements

- Linux machine with `systemd`
- Python 3
- `curl`
- `ss` or equivalent
- root or sudo privileges

## Quick start

```bash
chmod +x *.sh app.py
sudo bash setup_lab.sh
```

## Verify the setup

```bash
systemctl status payment-api
curl http://localhost:8080/health
ss -ltnp | grep 8080
```

Expected healthy response:

```json
{"status":"UP"}
```

## What you need to implement

Create a script named:

```bash
self-heal.sh
```

Your script should support at least:
- `check`
- `heal`
- `diagnose`

It should:
- verify `systemctl` service health
- verify listening port
- verify HTTP health endpoint
- restart service when needed
- collect diagnostics if recovery fails

## Failure scenarios for validation

### Stop the service
```bash
sudo bash failure_scenarios.sh stop-service
```

### Break health endpoint
```bash
sudo bash failure_scenarios.sh break-health
```

### Run on wrong port
```bash
sudo bash failure_scenarios.sh wrong-port
```

### Restore healthy state
```bash
sudo bash failure_scenarios.sh restore-health
sudo bash failure_scenarios.sh restore-port
```

## Suggested student flow

1. Install the lab
2. Verify healthy state
3. Implement `self-heal.sh`
4. Test `check` mode on healthy service
5. Stop the service and test `heal`
6. Break health endpoint and test unhealthy-but-running case
7. Move service to wrong port and verify port mismatch detection
8. Force recovery failure and verify diagnostics

## Cleanup

```bash
sudo systemctl stop payment-api
sudo systemctl disable payment-api
sudo rm -f /etc/systemd/system/payment-api.service
sudo rm -rf /etc/systemd/system/payment-api.service.d
sudo systemctl daemon-reload
sudo rm -rf /opt/payment-api-lab
```


# Answers to questions

## 1. What failure scenarios can your script detect, and which ones remain outside its scope?

**Detects:**
- service stopped,
- wrong port,
- unhealthy or unavailable health endpoint.

**Outside scope:**
- high CPU/RAM usage,
- database or external service failures,
- disk space and network issues.

## 2. Why is checking only `systemctl is-active` not enough to determine service health?

Because a service can be running but:
- not listening on the correct port,
- returning HTTP 500,
- not responding correctly.

## 3. What are the risks of automatic restart-based recovery?

- restart loops,
- temporary downtime,
- hiding the real problem.

## 4. What additional diagnostics would you collect in a production environment?

- CPU and memory usage,
- disk usage,
- process list,
- network connections,
- application logs.

## 5. How would you extend this tool to support multiple services?

- read services from a config file,
- check each service in a loop,
- generate separate reports.

## 6. How could this script be integrated into monitoring or alerting workflows?

It can be triggered by monitoring tool like Prometheus and send alerts if recovery fails.

## 7. What safeguards would you add to avoid restart loops or harmful self-healing behavior?

- limit restart attempts,
- add a cooldown time,
- notify an administrator after repeated failures.