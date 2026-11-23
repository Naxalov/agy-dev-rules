#!/usr/bin/env bash
set -euo pipefail

# Read-only environment and hardware collector for the /env-info skill.
# Explicitly excludes disk/space usage and never prints .env secret values.

TARGET_DIR="${1:-$(pwd)}"
OS_KERNEL="$(uname -s 2>/dev/null || echo unknown)"

read_dmi() {
  local field="$1"
  local path="/sys/class/dmi/id/${field}"
  if [[ -r "$path" ]]; then
    tr -d '\0' < "$path" 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
  fi
}

echo "=== OS & Host ==="
echo "Hostname: $(hostname 2>/dev/null || uname -n 2>/dev/null || echo unknown)"
echo "Kernel: $(uname -srm 2>/dev/null || uname -a)"
if [[ "$OS_KERNEL" == "Linux" ]]; then
  if [[ -r /etc/os-release ]]; then
    grep -E '^(PRETTY_NAME|VERSION_ID)=' /etc/os-release 2>/dev/null || true
  fi
elif [[ "$OS_KERNEL" == "Darwin" ]]; then
  echo "macOS: $(sw_vers -productName 2>/dev/null || echo macOS) $(sw_vers -productVersion 2>/dev/null || true) ($(sw_vers -buildVersion 2>/dev/null || true))"
fi
if command -v uptime >/dev/null 2>&1; then
  echo "Uptime: $(uptime -p 2>/dev/null || uptime | sed 's/^[[:space:]]*//')"
fi

echo ""
echo "=== Hardware Specifications ==="
if [[ "$OS_KERNEL" == "Linux" ]]; then
  sys_vendor="$(read_dmi sys_vendor)"
  product_name="$(read_dmi product_name)"
  product_version="$(read_dmi product_version)"
  board_vendor="$(read_dmi board_vendor)"
  board_name="$(read_dmi board_name)"
  bios_vendor="$(read_dmi bios_vendor)"
  bios_version="$(read_dmi bios_version)"

  [[ -n "$sys_vendor" ]] && echo "Manufacturer: $sys_vendor"
  [[ -n "$product_name" ]] && echo "Model: $product_name${product_version:+ ($product_version)}"
  [[ -n "$board_name" ]] && echo "Board: ${board_vendor:+$board_vendor }$board_name"
  [[ -n "$bios_vendor" ]] && echo "BIOS/Firmware: $bios_vendor${bios_version:+ $bios_version}"

  if command -v hostnamectl >/dev/null 2>&1; then
    hostnamectl 2>/dev/null | grep -E '^[[:space:]]*(Chassis|Virtualization|Hardware Vendor|Hardware Model|Firmware Version|Firmware Date):' | sed 's/^[[:space:]]*//' || true
  fi

  echo "--- CPU ---"
  if command -v lscpu >/dev/null 2>&1; then
    lscpu 2>/dev/null | grep -E '^(Architecture|Vendor ID|Model name|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)|CPU max MHz|CPU MHz|Hypervisor vendor|Virtualization type):' || true
  else
    echo "Architecture: $(uname -m)"
    echo "CPU(s): $(nproc 2>/dev/null || echo unknown)"
    if [[ -r /proc/cpuinfo ]]; then
      grep -m1 -E '^(vendor_id|model name)' /proc/cpuinfo || true
    fi
  fi

  echo "--- Memory ---"
  if command -v free >/dev/null 2>&1; then
    free -h | awk 'NR==1 || NR==2 || NR==3 {print}'
  elif [[ -r /proc/meminfo ]]; then
    grep -E '^(MemTotal|MemAvailable|SwapTotal|SwapFree):' /proc/meminfo || true
  fi
  if command -v swapon >/dev/null 2>&1; then
    swap_out="$(swapon --show 2>/dev/null || true)"
    if [[ -n "$swap_out" ]]; then
      echo "$swap_out"
    fi
  fi

  echo "--- GPU / Accelerators ---"
  gpu_found=0
  if command -v nvidia-smi >/dev/null 2>&1; then
    nv_out="$(nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader 2>/dev/null || true)"
    if [[ -n "$nv_out" ]]; then
      echo "$nv_out"
      gpu_found=1
    fi
  fi
  if [[ "$gpu_found" -eq 0 ]] && command -v lspci >/dev/null 2>&1; then
    pci_gpu="$(lspci 2>/dev/null | grep -iE '(VGA compatible controller|3D controller|Display controller)' || true)"
    if [[ -n "$pci_gpu" ]]; then
      echo "$pci_gpu"
      gpu_found=1
    fi
  fi
  if [[ "$gpu_found" -eq 0 ]]; then
    echo "None detected"
  fi

  echo "--- Storage Hardware (HDD / SSD) ---"
  disk_found=0
  if command -v lsblk >/dev/null 2>&1; then
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      name="$(echo "$line" | sed -n 's/.*NAME="\([^"]*\)".*/\1/p')"
      dtype="$(echo "$line" | sed -n 's/.*TYPE="\([^"]*\)".*/\1/p')"
      [[ "$dtype" != "disk" ]] && continue
      vendor="$(echo "$line" | sed -n 's/.*VENDOR="\([^"]*\)".*/\1/p' | xargs)"
      model="$(echo "$line" | sed -n 's/.*MODEL="\([^"]*\)".*/\1/p' | xargs)"
      size="$(echo "$line" | sed -n 's/.*SIZE="\([^"]*\)".*/\1/p' | xargs)"
      rota="$(echo "$line" | sed -n 's/.*ROTA="\([^"]*\)".*/\1/p' | xargs)"
      tran="$(echo "$line" | sed -n 's/.*TRAN="\([^"]*\)".*/\1/p' | xargs)"
      media_type="Unknown"
      if [[ "$rota" == "0" ]]; then
        media_type="SSD/Flash"
      elif [[ "$rota" == "1" ]]; then
        media_type="HDD/Rotational"
      fi
      desc="${vendor:+$vendor }${model:-Unknown Model}"
      echo "  /dev/${name}: ${desc} | Capacity: ${size:-?} | Media: ${media_type} (ROTA=${rota:-?})${tran:+ | Transport: ${tran}}"
      disk_found=1
    done < <(lsblk -dn -P -o NAME,TYPE,VENDOR,MODEL,SIZE,ROTA,TRAN 2>/dev/null || true)
  else
    for d in /sys/block/*; do
      [[ -d "$d" ]] || continue
      name="$(basename "$d")"
      [[ "$name" == loop* || "$name" == ram* || "$name" == zram* ]] && continue
      rota="$(cat "$d/queue/rotational" 2>/dev/null || echo '?')"
      vendor="$(tr -d '\0' < "$d/device/vendor" 2>/dev/null | xargs || true)"
      model="$(tr -d '\0' < "$d/device/model" 2>/dev/null | xargs || true)"
      media_type="Unknown"
      [[ "$rota" == "0" ]] && media_type="SSD/Flash"
      [[ "$rota" == "1" ]] && media_type="HDD/Rotational"
      echo "  /dev/${name}: ${vendor:+$vendor }${model:-Unknown Model} | Media: ${media_type} (ROTA=${rota})"
      disk_found=1
    done
  fi
  if [[ "$disk_found" -eq 0 ]]; then
    echo "  None detected"
  fi
elif [[ "$OS_KERNEL" == "Darwin" ]]; then
  echo "Manufacturer: Apple"
  if command -v system_profiler >/dev/null 2>&1; then
    system_profiler SPHardwareDataType 2>/dev/null | grep -E '^[[:space:]]*(Model Name|Model Identifier|Chip|Processor Name|Processor Speed|Total Number of Cores|Memory):' | sed 's/^[[:space:]]*//' || true
    echo "--- GPU / Displays ---"
    system_profiler SPDisplaysDataType 2>/dev/null | grep -E '^[[:space:]]*(Chipset Model|Total Number of Cores|VRAM):' | sed 's/^[[:space:]]*//' || true
    echo "--- Storage Hardware (HDD / SSD) ---"
    system_profiler SPNVMeDataType SPSerialATADataType 2>/dev/null | grep -E '^[[:space:]]*(Model|Capacity|Medium Type|Protocol|Link Width|Link Speed|TRIM Support):' | sed 's/^[[:space:]]*//' || true
  else
    echo "Model: $(sysctl -n hw.model 2>/dev/null || echo unknown)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo unknown) ($(sysctl -n hw.ncpu 2>/dev/null || echo ?) cores)"
    mem_bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
    if [[ "$mem_bytes" -gt 0 ]]; then
      echo "Memory: $((mem_bytes / 1024 / 1024 / 1024)) GiB"
    fi
  fi
else
  echo "Architecture: $(uname -m)"
fi

echo ""
echo "=== Workspace & VCS ==="
echo "Directory: $TARGET_DIR"
if [[ -d "$TARGET_DIR" ]]; then
  if command -v git >/dev/null 2>&1 && git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Git repo: yes"
    echo "Branch: $(git -C "$TARGET_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
    echo "Commit: $(git -C "$TARGET_DIR" log -1 --oneline 2>/dev/null || echo none)"
    dirty_count="$(git -C "$TARGET_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    echo "Working tree: ${dirty_count} modified/untracked item(s)"
  else
    echo "Git repo: no"
  fi
fi

echo ""
echo "=== Runtimes & Developer Tools ==="
check_tool() {
  local name="$1"
  shift
  local bin_path
  bin_path="$(command -v "$name" 2>/dev/null || true)"
  if [[ -n "$bin_path" ]]; then
    local ver=""
    if [[ "$#" -gt 0 ]]; then
      ver="$("$@" 2>&1 | head -n 1 || true)"
    fi
    echo "  [installed] ${name}: ${bin_path}${ver:+ (${ver})}"
  else
    echo "  [missing]   ${name}"
  fi
}

check_tool python3 python3 --version
if [[ -x "${TARGET_DIR}/.venv/bin/python" ]]; then
  echo "  [venv]      .venv/bin/python: $("${TARGET_DIR}/.venv/bin/python" --version 2>&1 | head -n 1 || true)"
fi
check_tool uv uv --version
check_tool node node --version
check_tool npm npm --version
check_tool npx npx --version
check_tool pnpm pnpm --version
check_tool bun bun --version
check_tool go go version
check_tool cargo cargo --version
check_tool git git --version
check_tool docker docker --version
check_tool ffmpeg ffmpeg -version
check_tool nginx nginx -v
check_tool caddy caddy version
check_tool agy agy --version

echo ""
echo "=== Services ==="
if [[ -x "${TARGET_DIR}/scripts/dev.sh" ]]; then
  echo "--- Project dev.sh status ---"
  (cd "$TARGET_DIR" && ./scripts/dev.sh status 2>/dev/null || true)
fi
if [[ "$OS_KERNEL" == "Linux" ]] && command -v systemctl >/dev/null 2>&1; then
  echo "--- Notable Running Systemd Services ---"
  svc_out="$(systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null \
    | grep -iE '(nginx|caddy|apache|httpd|docker|containerd|postgres|mysql|mariadb|redis|mongo|agent|bot|uvicorn|gunicorn|node|python|worker|api|web)' \
    | awk '{$1=$1; print "  " $0}' || true)"
  if [[ -n "$svc_out" ]]; then
    echo "$svc_out"
  else
    echo "  None matched"
  fi
fi

echo ""
echo "=== Environment Files (Keys Only — Values Redacted) ==="
env_found=0
for rel in .env .env.local .env.development .env.production backend/.env server/.env web/.env; do
  fpath="${TARGET_DIR}/${rel}"
  if [[ -f "$fpath" && -r "$fpath" ]]; then
    env_found=1
    echo "File: ${rel}"
    grep -E '^[[:space:]]*(export[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*=' "$fpath" 2>/dev/null \
      | sed -E 's/^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=.*/  - \2/' || true
  fi
done
if [[ "$env_found" -eq 0 ]]; then
  echo "No readable .env files found in standard locations."
fi
