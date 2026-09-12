#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./tools/windows-vm/run-windows-vm.sh <windows-iso-or-vhdx> [disk-image]

Examples:
  ./tools/windows-vm/run-windows-vm.sh /mnt/data/Win11_English_x64.iso
  ./tools/windows-vm/run-windows-vm.sh /mnt/data/Win10.vhdx /mnt/data/win10.qcow2

This starts a KVM-backed Windows VM for the project's Windows portable build flow.

Notes:
  - The ISO or VHDX must be a legal Windows install image.
  - The VM is headless and exposes VNC on localhost:5901.
  - Optional browser access via noVNC: http://localhost:6080/vnc.html
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

SOURCE_PATH="$1"
DISK_PATH="${2:-/tmp/redpanda-windows.qcow2}"
WORK_DIR="$(dirname "$DISK_PATH")"
mkdir -p "$WORK_DIR"

if [[ ! -f "$SOURCE_PATH" ]]; then
  echo "Windows image not found: $SOURCE_PATH" >&2
  exit 1
fi

if [[ ! -f "$DISK_PATH" ]]; then
  echo "Creating VM disk: $DISK_PATH"
  qemu-img create -f qcow2 "$DISK_PATH" 64G
fi

if [[ "$SOURCE_PATH" == *.iso ]]; then
  MEDIA_ARGS=(-drive "file=$SOURCE_PATH,media=cdrom,readonly=on")
else
  MEDIA_ARGS=(-drive "file=$SOURCE_PATH,if=virtio,format=raw")
fi

QEMU_BIN="$(command -v qemu-system-x86_64 || true)"
if [[ -z "$QEMU_BIN" ]]; then
  echo "qemu-system-x86_64 not found" >&2
  exit 1
fi

exec "$QEMU_BIN" \
  -machine accel=kvm -cpu host \
  -m 8192 \
  -smp 4 \
  -display none \
  -vnc 127.0.0.1:1 \
  -rtc base=localtime \
  -nic user,model=virtio-net-pci \
  -drive "file=$DISK_PATH,if=virtio,format=qcow2" \
  "${MEDIA_ARGS[@]}" \
  -boot order=d \
  -daemonize
