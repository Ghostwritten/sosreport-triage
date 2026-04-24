# Case: disk-full-write-failure

## Scenario

Customer reports application write failures and service instability after a period of normal operation.

## Key Evidence

- `sos_commands/filesys/df_-al`: application or root filesystem is at or near full
- `sos_commands/filesys/mount`: affected mount is writable in principle
- `var/log/` or `sos_commands/logs/`: `No space left on device` appears in logs
- `sos_commands/kernel/dmesg`: filesystem may show remount or write-failure messages

## Expected Assessment

### Observed facts

- The relevant filesystem has no practical free space left.
- Logs show write failures consistent with capacity exhaustion.

### Likely impact or risk

- Strong evidence that filesystem exhaustion is directly impacting application behavior.

### Most likely explanations

- Disk capacity exhaustion is the leading explanation for the customer-visible failures.
- If remount or filesystem errors also appear, the incident may include both capacity and filesystem integrity concerns.

### Evidence gaps

- Snapshot data may not identify which growth path consumed the space unless logs or directory evidence point to it.

## Severity

- severity: `Critical`
- confidence: `High`

## Common Misreads

- `tmpfs is full, so root disk is full`
- `high usage without write failures always means outage root cause`
