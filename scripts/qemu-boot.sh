#!/bin/bash
# Boot the compiled kernel in QEMU with a minimal initrd
# Kernel: src/linux-torvalds/arch/x86/boot/bzImage
# Initrd: fetched from https://linux.mauri870.com/init.cpio.lzma

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BZIMAGE="$REPO_ROOT/src/linux-torvalds/arch/x86/boot/bzImage"
INITRD="$REPO_ROOT/build/init.cpio.lzma"
INITRD_URL="https://linux.mauri870.com/init.cpio.lzma"

if [[ ! -f "$BZIMAGE" ]]; then
  echo "error: bzImage not found at $BZIMAGE" >&2
  echo "Build the kernel first with: makepkg" >&2
  exit 1
fi

if [[ ! -f "$INITRD" ]]; then
  echo "Fetching initrd from $INITRD_URL..."
  mkdir -p "$(dirname "$INITRD")"
  curl -fL -o "$INITRD" "$INITRD_URL"
fi

exec qemu-system-x86_64 \
  -m 4G \
  -cpu host \
  -enable-kvm \
  -no-reboot \
  -serial stdio \
  -kernel "$BZIMAGE" \
  -initrd "$INITRD" \
  -append "console=ttyS0 earlyprintk=ttyS0 panic=-1 nokaslr" \
  "$@"
