# Compatibility And Fallback Guidance

`sosreport` layouts vary by distro, plugin set, and collection age. Missing paths are normal.

## General Rule

For each evidence group:

1. check the preferred path
2. check the fallback paths
3. if all are missing, record the group as unavailable
4. lower confidence rather than fabricating a conclusion

## Memory

Preferred paths:

- `sos_commands/memory/free`
- `proc/meminfo`
- `sos_commands/memory/swapon_-s`

Fallback guidance:

- if `free` output is missing, prefer `proc/meminfo`
- if `swapon_-s` is missing, use `proc/meminfo` swap fields if present
- if `buddyinfo` is missing, skip fragmentation analysis rather than inferring it

## CPU And Load

Preferred paths:

- `sos_commands/processor/lscpu`
- `proc/cpuinfo`
- `uptime`
- `sos_commands/host/uptime`
- `proc/loadavg`

Fallback guidance:

- if `lscpu` is missing, count processors from `proc/cpuinfo`
- if `uptime` export is missing, use `proc/loadavg`
- if only a single load source exists, do not imply trend or persistence

## Disk And Filesystems

Preferred paths:

- `sos_commands/filesys/df_-al`
- `sos_commands/block/lsblk`
- `sos_commands/filesys/mount`
- `proc/diskstats`
- `sos_commands/kernel/dmesg`

Fallback guidance:

- if `df_-al` is missing, use any available `df` export under `sos_commands/filesys/`
- if `lsblk` is missing, rely on `mount` and filesystem evidence only
- if `dmesg` is missing or truncated, search `var/log/` and `sos_commands/logs/`

## Process State

Preferred paths:

- `sos_commands/process/ps_auxwww`
- `sos_commands/process/top`

Fallback guidance:

- if `top` is missing, use `ps` for top memory and CPU consumers
- if process snapshots are incomplete, avoid claims about transient spikes

## Logs

Common locations:

- `sos_commands/logs/`
- `sos_commands/systemd/`
- `var/log/`

Search terms:

- `oom`
- `out of memory`
- `killed process`
- `blocked for more than`
- `i/o error`
- `read-only`
- `no space left`
- `watchdog`
- `throttl`

## Distro Notes

- RHEL-family reports often provide both `sos_commands/*` and `proc/*`, but not always both.
- Older collections may rely more heavily on flat files under `var/log/`.
- Some plugin sets omit process or memory detail entirely; treat that as an evidence gap, not as absence of a problem.

## Reporting Rule

When an entire evidence group is unavailable, mention it in `Evidence gaps` and avoid overconfident conclusions about that subsystem.
