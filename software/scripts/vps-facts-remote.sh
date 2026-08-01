#!/usr/bin/env bash

set -u

machine_output=false
if [[ "${1:-}" == "--machine" ]]; then
  machine_output=true
fi

for command in ip lsblk readlink; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'ERROR: required command not found: %s\n' "$command" >&2
    exit 1
  fi
done

if [[ -d /sys/firmware/efi ]]; then
  boot_mode="uefi"
else
  boot_mode="bios"
fi

default_route="$(ip -4 route show default 2>/dev/null | awk 'NR == 1 { print; exit }')"
interface="$(awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }' <<<"$default_route")"
gateway="$(awk '{ for (i = 1; i <= NF; i++) if ($i == "via") { print $(i + 1); exit } }' <<<"$default_route")"

cidr=""
address=""
prefix_length=""
if [[ -n "$interface" ]]; then
  cidr="$(ip -o -4 address show dev "$interface" scope global 2>/dev/null | awk 'NR == 1 { print $4; exit }')"
fi
if [[ "$cidr" == */* ]]; then
  address="${cidr%/*}"
  prefix_length="${cidr#*/}"
fi

disk_ids=()
disk_targets=()
shopt -s nullglob
for link in /dev/disk/by-id/*; do
  [[ "$link" == *-part[0-9]* ]] && continue
  resolved="$(readlink -f "$link" 2>/dev/null || true)"
  [[ -n "$resolved" ]] || continue
  type="$(lsblk -dn -o TYPE "$resolved" 2>/dev/null | awk 'NR == 1 { print; exit }')"
  if [[ "$type" == "disk" ]]; then
    disk_ids+=("$link")
    disk_targets+=("$resolved")
  fi
done
shopt -u nullglob

if $machine_output; then
  printf 'FACT\tbootMode\t%s\n' "$boot_mode"
  printf 'FACT\tinterface\t%s\n' "$interface"
  printf 'FACT\taddress\t%s\n' "$address"
  printf 'FACT\tprefixLength\t%s\n' "$prefix_length"
  printf 'FACT\tgateway\t%s\n' "$gateway"
  for index in "${!disk_ids[@]}"; do
    printf 'DISK\t%s\t%s\n' "${disk_ids[$index]}" "${disk_targets[$index]}"
  done
  exit 0
fi

printf '=== Firmware ===\n'
printf 'bootMode: %s\n\n' "$boot_mode"

printf '=== Whole disks ===\n'
lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,MODEL,SERIAL,TRAN,MOUNTPOINTS
printf '\n=== Stable whole-disk IDs ===\n'

if ((${#disk_ids[@]} == 0)); then
  printf '(none found)\n'
else
  for index in "${!disk_ids[@]}"; do
    printf '%s -> %s\n' "${disk_ids[$index]}" "${disk_targets[$index]}"
  done
fi

printf '\n=== Network ===\n'
printf 'Default interface: %s\n' "${interface:-not found}"
printf 'Observed IPv4 CIDR: %s\n' "${cidr:-not found}"
printf 'Observed IPv4 gateway: %s\n' "${gateway:-not found}"
printf '\nLinks:\n'
ip -br link
printf '\nIPv4 addresses:\n'
ip -4 address
printf '\nIPv4 routes:\n'
ip -4 route
printf '\nIPv6 addresses:\n'
ip -6 address
printf '\nIPv6 routes:\n'
ip -6 route

printf '\n=== instance.nix starting point ===\n'
printf '{\n'
printf '  deploymentReady = false;\n'
if ((${#disk_ids[@]} == 1)); then
  printf '  disk = "%s";\n' "${disk_ids[0]}"
else
  printf '  disk = "/dev/disk/by-id/CHOOSE_FROM_LIST_ABOVE";\n'
fi
printf '  bootMode = "%s";\n' "$boot_mode"
printf '  interface = "%s";\n' "${interface:-REPLACE_ME}"
printf '\n'
printf '  ipv4 = {\n'
printf '    address = "%s";\n' "${address:-REPLACE_ME}"
printf '    prefixLength = %s;\n' "${prefix_length:-REPLACE_ME}"
printf '    gateway = "%s";\n' "${gateway:-REPLACE_ME}"
printf '  };\n'
printf '}\n'

printf '\nVerify IPv4 address, prefix, and gateway against the Contabo panel.\n'
printf 'Choose the intended whole-disk ID manually.\n'
printf 'Set deploymentReady = true only after every value is verified.\n'
