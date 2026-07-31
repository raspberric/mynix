#!/usr/bin/env bash

set -u

failures=0
warnings=0

pass() {
  printf 'PASS: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
  warnings=$((warnings + 1))
}

fail() {
  printf 'FAIL: %s\n' "$1"
  failures=$((failures + 1))
}

printf 'nixos-anywhere kexec preflight for %s\n\n' "$(hostname 2>/dev/null || printf unknown)"

if [[ "$(uname -s)" == "Linux" ]]; then
  pass "operating system is Linux"
else
  fail "operating system must be Linux"
fi

if [[ "$(uname -m)" == "x86_64" ]]; then
  pass "architecture is x86_64"
else
  fail "this flake requires x86_64, found $(uname -m)"
fi

if [[ "$(id -u)" -eq 0 ]]; then
  pass "SSH user is root"
elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
  pass "SSH user has passwordless sudo"
else
  fail "use root or a user with passwordless sudo"
fi

mem_kib="$(awk '/^MemTotal:/ { print $2; exit }' /proc/meminfo 2>/dev/null || true)"
if [[ "$mem_kib" =~ ^[0-9]+$ ]]; then
  if ((mem_kib >= 1572864)); then
    pass "RAM is at least 1.5 GiB excluding swap"
  else
    fail "nixos-anywhere requires at least 1.5 GiB RAM excluding swap; found $((mem_kib / 1024)) MiB"
  fi
else
  fail "could not read physical RAM from /proc/meminfo"
fi

for command in tar cpio setsid; do
  if command -v "$command" >/dev/null 2>&1; then
    pass "$command is available"
  else
    fail "$command is required by nixos-anywhere"
  fi
done

if command -v setsid >/dev/null 2>&1; then
  if setsid --help 2>&1 | grep -q -- '--wait'; then
    pass "setsid supports --wait"
  else
    fail "setsid must support --wait"
  fi
fi

if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
  pass "remote host can download the kexec image"
else
  warn "neither curl nor wget exists; nixos-anywhere must upload the image from the source machine"
fi

if [[ -e /sys/kernel/kexec_loaded ]]; then
  pass "kernel exposes kexec support"
else
  fail "kernel does not expose /sys/kernel/kexec_loaded; CONFIG_KEXEC may be disabled"
fi

if [[ -r /proc/sys/kernel/kexec_load_disabled ]]; then
  kexec_disabled="$(< /proc/sys/kernel/kexec_load_disabled)"
  if [[ "$kexec_disabled" == "0" ]]; then
    pass "kernel.kexec_load_disabled is 0"
  else
    fail "kernel.kexec_load_disabled is $kexec_disabled"
  fi
else
  warn "kernel.kexec_load_disabled could not be read"
fi

if [[ -r /sys/kernel/security/lockdown ]]; then
  lockdown="$(< /sys/kernel/security/lockdown)"
  if [[ "$lockdown" == *"[none]"* ]]; then
    pass "kernel lockdown is disabled"
  else
    fail "kernel lockdown is active: $lockdown"
  fi
else
  pass "no active kernel lockdown interface found"
fi

if command -v systemd-detect-virt >/dev/null 2>&1; then
  container="$(systemd-detect-virt --container 2>/dev/null || true)"
  if [[ -n "$container" && "$container" != "none" ]]; then
    fail "target is a $container container, not a VM or physical machine"
  else
    pass "target is not detected as a container"
  fi
fi

printf '\n'
if ((failures == 0)); then
  printf 'RESULT: preflight passed with %d warning(s).\n' "$warnings"
  printf 'This is non-destructive; only loading and executing a kernel can prove kexec completely.\n'
  exit 0
fi

printf 'RESULT: preflight failed with %d failure(s) and %d warning(s).\n' "$failures" "$warnings"
exit 1
