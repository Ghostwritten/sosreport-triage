# Case: io-wait-dstate

## Scenario

Customer reports host slowness and application timeouts, but CPU utilization does not appear saturated.

## Key Evidence

- `proc/loadavg` or `uptime`: load average is materially above CPU count
- `sos_commands/process/ps_auxwww`: many tasks are in `D` state
- `sos_commands/kernel/dmesg`: storage or filesystem error messages are present
- `proc/diskstats`: device activity looks elevated or abnormal

## Expected Assessment

### Observed facts

- Load is high relative to CPU count.
- Process state shows blocked tasks.
- Kernel or system logs contain storage-related fault evidence.

### Likely impact or risk

- Strong evidence that host responsiveness is being degraded by storage wait or fault behavior rather than pure CPU contention.

### Most likely explanations

- I/O wait or storage-layer failure is the leading explanation for the slowdown.
- High load in this case should not be interpreted as ordinary CPU saturation.

### Evidence gaps

- Without full storage telemetry, the exact device or layer may remain unclear.

## Severity

- severity: `Critical`
- confidence: `High`

## Common Misreads

- `high load always means CPU is busy`
- `top CPU consumers explain the problem even when many tasks are blocked`
