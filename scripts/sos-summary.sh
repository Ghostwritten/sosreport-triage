#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /path/to/extracted-sosreport" >&2
  exit 1
fi

root=$1

if [[ ! -d "$root" ]]; then
  echo "error: directory not found: $root" >&2
  exit 1
fi

find_first() {
  local path
  for path in "$@"; do
    if [[ -f "$root/$path" ]]; then
      printf '%s\n' "$root/$path"
      return 0
    fi
  done
  return 1
}

print_header() {
  printf '\n== %s ==\n' "$1"
}

print_path_or_missing() {
  local label=$1
  shift
  local found
  if found=$(find_first "$@" 2>/dev/null); then
    printf '%s: %s\n' "$label" "${found#$root/}"
  else
    printf '%s: MISSING\n' "$label"
  fi
}

print_grep_hits() {
  local label=$1
  local path=$2
  local pattern=$3

  if [[ -f "$path" ]]; then
    printf '%s\n' "$label"
    grep -Ein "$pattern" "$path" | head -n 10 || true
  else
    printf '%s\nMISSING\n' "$label"
  fi
}

meminfo=$(find_first "proc/meminfo" "sos_commands/memory/free" || true)
swapinfo=$(find_first "sos_commands/memory/swapon_-s" || true)
buddyinfo=$(find_first "proc/buddyinfo" || true)
lscpu=$(find_first "sos_commands/processor/lscpu" "proc/cpuinfo" || true)
uptime_file=$(find_first "uptime" "sos_commands/host/uptime" "proc/loadavg" || true)
df_file=$(find_first "sos_commands/filesys/df_-al" || true)
lsblk_file=$(find_first "sos_commands/block/lsblk" || true)
mount_file=$(find_first "sos_commands/filesys/mount" || true)
diskstats=$(find_first "proc/diskstats" || true)
ps_file=$(find_first "sos_commands/process/ps_auxwww" || true)
top_file=$(find_first "sos_commands/process/top" || true)
dmesg_file=$(find_first "sos_commands/kernel/dmesg" || true)

print_header "Summary"
printf 'root: %s\n' "$root"

print_header "Available evidence"
print_path_or_missing "memory" "proc/meminfo" "sos_commands/memory/free"
print_path_or_missing "swap" "sos_commands/memory/swapon_-s"
print_path_or_missing "buddyinfo" "proc/buddyinfo"
print_path_or_missing "cpu" "sos_commands/processor/lscpu" "proc/cpuinfo"
print_path_or_missing "load" "uptime" "sos_commands/host/uptime" "proc/loadavg"
print_path_or_missing "df" "sos_commands/filesys/df_-al"
print_path_or_missing "lsblk" "sos_commands/block/lsblk"
print_path_or_missing "mount" "sos_commands/filesys/mount"
print_path_or_missing "diskstats" "proc/diskstats"
print_path_or_missing "ps" "sos_commands/process/ps_auxwww"
print_path_or_missing "top" "sos_commands/process/top"
print_path_or_missing "dmesg" "sos_commands/kernel/dmesg"

print_header "Memory snapshot"
if [[ -n "${meminfo:-}" && "$(basename "$meminfo")" == "meminfo" ]]; then
  grep -E '^(MemTotal|MemAvailable|MemFree|SwapTotal|SwapFree):' "$meminfo" || true
elif [[ -n "${meminfo:-}" ]]; then
  head -n 10 "$meminfo" || true
else
  echo "MISSING"
fi

if [[ -n "${swapinfo:-}" ]]; then
  printf '\n-- swap detail --\n'
  cat "$swapinfo"
fi

if [[ -n "${buddyinfo:-}" ]]; then
  printf '\n-- buddyinfo sample --\n'
  head -n 5 "$buddyinfo"
fi

print_header "CPU and load snapshot"
if [[ -n "${lscpu:-}" && "$(basename "$lscpu")" == "lscpu" ]]; then
  grep -E '^(CPU\\(s\\)|Model name|Thread\\(s\\) per core|Core\\(s\\) per socket|Socket\\(s\\)):' "$lscpu" || true
elif [[ -n "${lscpu:-}" ]]; then
  grep -E '^(processor|model name)' "$lscpu" | head -n 12 || true
else
  echo "MISSING"
fi

if [[ -n "${uptime_file:-}" ]]; then
  printf '\n-- load source --\n'
  head -n 3 "$uptime_file"
else
  echo "load source: MISSING"
fi

print_header "Disk and filesystem snapshot"
if [[ -n "${df_file:-}" ]]; then
  head -n 20 "$df_file"
else
  echo "df: MISSING"
fi

if [[ -n "${mount_file:-}" ]]; then
  printf '\n-- mounts --\n'
  head -n 20 "$mount_file"
fi

if [[ -n "${lsblk_file:-}" ]]; then
  printf '\n-- block devices --\n'
  head -n 20 "$lsblk_file"
fi

if [[ -n "${diskstats:-}" ]]; then
  printf '\n-- diskstats sample --\n'
  head -n 10 "$diskstats"
fi

print_header "Process snapshot"
if [[ -n "${ps_file:-}" ]]; then
  head -n 15 "$ps_file"
else
  echo "ps: MISSING"
fi

if [[ -n "${top_file:-}" ]]; then
  printf '\n-- top snapshot --\n'
  head -n 20 "$top_file"
fi

print_header "Correlated log hints"
if [[ -n "${dmesg_file:-}" ]]; then
  print_grep_hits "-- dmesg critical terms --" "$dmesg_file" 'oom|out of memory|killed process|blocked for more than|i/o error|read-only|no space left|watchdog|throttl'
else
  echo "dmesg: MISSING"
fi

log_root=""
for candidate in "$root/sos_commands/logs" "$root/sos_commands/systemd" "$root/var/log"; do
  if [[ -d "$candidate" ]]; then
    log_root=$candidate
    break
  fi
done

printf '\n-- additional logs --\n'
if [[ -n "$log_root" ]]; then
  printf 'log root: %s\n' "${log_root#$root/}"
  grep -EIRin 'oom|out of memory|killed process|blocked for more than|i/o error|read-only|no space left|watchdog|throttl' "$log_root" | head -n 20 || true
else
  echo "MISSING"
fi

print_header "Analyst reminders"
cat <<'EOF'
- Treat this output as a first-pass fact index, not a final diagnosis.
- Distinguish observed facts from inferred explanations.
- Lower confidence if key evidence groups are missing.
- Do not claim trend, duration, or root cause unless logs support it.
EOF
