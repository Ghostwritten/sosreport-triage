---
name: Sosreport Triage
description: Analyze resource pressure from an extracted sosreport using minimal, file-backed evidence across memory, CPU, disk, and process state, then report concise findings with uncertainty.
---

# Sosreport Triage

Use this skill for offline analysis of a customer-provided, already extracted `sosreport`.

Goal: decide whether host resource pressure likely contributed to an incident, using concise, path-cited evidence.

## Use When

- user wants memory, CPU, disk, or process-pressure analysis from `sosreport`
- user wants to judge whether resource exhaustion likely contributed to a failure
- user wants a short support-style assessment with clear uncertainty

## Do Not Use When

- the issue is mainly Kubernetes control-plane behavior
- the issue is primarily MySQL internals or query behavior
- the user needs live telemetry or trend analysis

## Working Rules

- Treat `sosreport` as a snapshot unless logs prove a timeline.
- Missing files are normal; use fallbacks and lower confidence.
- Do not infer root cause from one threshold alone.
- Keep the answer short; cite file paths for nontrivial findings.

## Minimal Evidence Paths

Check the first available path in each group.

- memory: `proc/meminfo`, `sos_commands/memory/free`, `sos_commands/memory/swapon_-s`, `proc/buddyinfo`
- CPU/load: `sos_commands/processor/lscpu`, `proc/cpuinfo`, `uptime`, `sos_commands/host/uptime`, `proc/loadavg`
- disk: `sos_commands/filesys/df_-al`, `sos_commands/block/lsblk`, `sos_commands/filesys/mount`, `proc/diskstats`, `sos_commands/kernel/dmesg`
- processes: `sos_commands/process/ps_auxwww`, `sos_commands/process/top`
- logs: `sos_commands/logs/`, `sos_commands/systemd/`, `var/log/`

If a whole evidence group is unavailable, state that in `Evidence gaps`.

## Analysis Order

1. Snapshot quality
   Check which evidence groups are present and narrow confidence early if key groups are missing.
2. Memory
   Prefer `MemAvailable`; check swap use, OOM/allocation failures, and outsized RSS consumers.
3. CPU/load
   Establish CPU count before interpreting load; high load plus many `D` tasks suggests I/O wait, not CPU saturation.
4. Disk
   Check real filesystems, not pseudo filesystems by default; look for near-full filesystems, write failures, read-only remounts, and I/O errors.
5. Process state
   Look for top CPU or memory consumers, `D` accumulation, abnormal counts, and only treat `Z` as meaningful when repeated or numerous.
6. Correlation
   Only connect resource pressure to failure when logs or clear service symptoms support it.

## Interpretation Shortcuts

- low `MemAvailable` + swap + OOM log => strong memory-pressure evidence
- load above CPU count + low CPU consumption + many `D` tasks => storage-wait suspicion
- filesystem near full + `No space left` or write failure => strong disk-impact evidence
- swap use alone, high cache alone, or 1-minute load alone => not enough

## Output Format

Use exactly this structure:

1. `Observed facts`
2. `Likely impact or risk`
3. `Most likely explanations`
4. `Evidence gaps`

Keep facts and inference separate. If correlation is weak, say `risk signal` rather than `root cause`.

## Guardrails

- Do not invent values.
- Do not assume a standard `sosreport` layout.
- Do not claim trend or start time without timestamped log support.
- Do not call root cause without at least one corroborating failure signal.
- If evidence conflicts, say so explicitly.

## Companion Assets

Load only when needed:

- `docs/rubric.md`: severity and confidence calibration
- `docs/compatibility.md`: distro/path fallbacks
- `cases/`: replayable examples
- `scripts/sos-summary.sh`: local first-pass summary helper
