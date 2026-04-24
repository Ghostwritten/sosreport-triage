# Case: memory-oom

## Scenario

Customer reports abrupt service restarts and intermittent request failures.

## Key Evidence

- `proc/meminfo`: `MemAvailable` is very low relative to `MemTotal`
- `sos_commands/memory/swapon_-s`: swap is in active use
- `sos_commands/kernel/dmesg`: `OOM killer` and `Killed process` messages are present
- `sos_commands/process/ps_auxwww`: one application process is a dominant RSS consumer

## Expected Assessment

### Observed facts

- Memory headroom is low in the snapshot.
- Swap is active.
- Kernel logs contain OOM kill evidence.
- One process appears to be the dominant memory consumer.

### Likely impact or risk

- Strong evidence of real memory exhaustion affecting workload stability.

### Most likely explanations

- Memory pressure is the leading explanation for the reported restarts.
- The large application process may be the proximate trigger, but workload expectations still need validation before calling it a leak.

### Evidence gaps

- No time-series data shows whether this is chronic growth or a burst event.

## Severity

- severity: `Critical`
- confidence: `High`

## Common Misreads

- `cache is high, therefore memory is broken`
- `one large RSS process automatically means memory leak`
