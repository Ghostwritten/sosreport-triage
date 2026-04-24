# Severity And Evidence Rubric

Use this rubric after collecting facts from the `sosreport`.

## Core Rule

Do not assign severity from a single threshold alone. Prefer evidence combinations.

## Evidence Strength

### Strong evidence

Use when a resource signal is directly corroborated by failure evidence.

Examples:

- `OOM killer` messages plus low `MemAvailable`
- filesystem at or near full plus write failures
- repeated I/O errors plus many `D` state tasks
- read-only remount plus application write failures

### Medium evidence

Use when the signal is real, but impact is only partially shown.

Examples:

- swap in active use with low available memory, but no OOM event
- load materially above CPU count with matching hot processes
- filesystem very full without a logged application failure

### Weak evidence

Use when there is only a pressure hint and no corroboration.

Examples:

- high memory usage percentage alone
- swap used alone
- 1-minute load spike alone
- one large process without behavioral evidence

## Severity Matrix

### `Critical`

Assign when both conditions are true:

- strong evidence of active exhaustion or severe resource fault exists
- impact to workload stability, service health, or host operation is visible

Typical patterns:

- OOM kills or allocation failures affecting services
- full filesystem with write failures or read-only remount
- repeated disk I/O errors with blocked tasks and service symptoms

### `Warning`

Assign when at least one of these is true:

- resource pressure is clear but direct impact is incomplete
- evidence suggests a credible near-term capacity risk
- the signal likely contributed to symptoms, but causality is not fully proven

Typical patterns:

- low available memory and swap use without OOM
- very high load with clear hot processes, but no confirmed outage
- filesystem nearing exhaustion without explicit write failures

### `OK`

Assign when available evidence does not show meaningful resource pressure.

Typical patterns:

- memory headroom looks normal
- load is consistent with CPU count and workload
- no material disk pressure or error signals
- process state looks ordinary

### `Unknown`

Assign when the evidence set is too incomplete or too conflicting to judge safely.

Typical patterns:

- key files are missing for the suspected subsystem
- snapshot shows mixed signals with no corroborating logs
- data is stale, truncated, or clearly inconsistent

## Confidence Guidance

Use a simple confidence tag in your notes:

- `High`: multiple corroborating files point to the same conclusion
- `Medium`: the leading explanation is plausible, but one major gap remains
- `Low`: weak or conflicting evidence; report only risk, not root cause

## Support-Engineer Decision Rules

- Say `leading explanation` when evidence is medium or strong but not conclusive.
- Say `risk signal` when evidence is weak or incomplete.
- Say `root cause` only when at least one direct failure signal and one corroborating resource signal align.
- If a fallback path was used because the preferred file was missing, mention that explicitly.
