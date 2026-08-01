#!/usr/bin/env bash

set -u

for command in awk ip lsblk readlink; do
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

printf 'FACT\tbootMode\t%s\n' "$boot_mode"
printf 'FACT\tinterface\t%s\n' "$interface"
printf 'FACT\taddress\t%s\n' "$address"
printf 'FACT\tprefixLength\t%s\n' "$prefix_length"
printf 'FACT\tgateway\t%s\n' "$gateway"
for index in "${!disk_ids[@]}"; do
  printf 'DISK\t%s\t%s\n' "${disk_ids[$index]}" "${disk_targets[$index]}"
done
