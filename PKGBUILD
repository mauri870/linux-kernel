# Maintainer: Mauri de Souza Meneguzzo <mauri870@gmail.com>

pkgbase=linux-mauri870
pkgver=7.1.0.rc2
pkgrel=1
pkgdesc="My custom Linux with added patches and optimizations"
url="https://www.kernel.org"
arch=(x86_64)
license=(GPL-2.0-only)
makedepends=(
  bc
  bison
  clang
  cpio
  flex
  gettext
  git
  libelf
  llvm
  lld
  pahole
  perl
  polly
  python
  rust
  rust-bindgen
  rust-src
  tar
  xz
)
options=(
  !debug
  !strip
)
_srcname=linux-torvalds
_url="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
source=(
  config
  0001-hdmi_frl.patch
  0002-bore.patch
  0003-clang-polly.patch
  0004-mm_lazy_rss_stat.patch
  0005-cflags-O3.patch
  0006-disable-split-lock.patch
  0007-tcp-bbr3.patch
  0009-tick-nohz-fix-wrong-nohz-idle-cpu-state.patch
  0010-posted-msi-enable-by-default.patch
  0011-sched-better-idle-balance.patch
  0012-mm-max-map-count-INT-MAX.patch
  0013-net-sock-SK_MEM_PACKETS-1024.patch
  0014-sched-ratelimit-yield.patch
  0015-mm-libs-grow-down.patch
  0016-mm-mmput-async.patch
  0017-cgroup-vram.patch
  0018-slack.patch
  0019-rwsem-spin-faster.patch
  0020-ata-before-graphics.patch
  0021-sched-wait-lifo-accept.patch
  0022-tcp-write-buffer.patch
)
b2sums=(
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
  'SKIP'
)

export LINUX_COMMIT=7fd2df204f342fc17d1a0bfcd474b24232fb0f32
export KBUILD_BUILD_HOST=archlinux
export KBUILD_BUILD_USER=$pkgbase
export KBUILD_BUILD_TIMESTAMP="$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})"

prepare() {
  if [[ ! -d "$_srcname/.git" ]]; then
    echo "Cloning linux repository..."
    rm -rf "$_srcname"
    git clone --filter=blob:none "$_url" "$_srcname"
  fi

  cd "$_srcname"

  echo "Enforcing commit $LINUX_COMMIT..."
  git fetch origin
  git checkout -f "$LINUX_COMMIT"

  local patch_stamp=".patch-stamp"
  local patch_hash
  patch_hash=$(cat "${source[@]/#/..\/}" 2>/dev/null | b2sum | cut -d' ' -f1) || patch_hash=""

  if [[ ! -f "$patch_stamp" ]] || [[ "$(cat "$patch_stamp")" != "$patch_hash" ]] || git diff --quiet HEAD; then
    echo "Patches changed, resetting tree..."
    git checkout "$LINUX_COMMIT"
    git reset --hard HEAD
    git clean -fdx

    local src
    for src in "${source[@]}"; do
      src="${src%%::*}"
      src="${src##*/}"
      [[ $src = 0[0-9]*.patch ]] || continue
      echo "Applying patch $src..."
      git apply "../$src"
    done

    echo "$patch_hash" > "$patch_stamp"
  else
    echo "Patches unchanged, skipping reset."
  fi

  echo "Setting version..."
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux}" > localversion.20-pkgname

  echo "Setting config..."
  cp ../config .config
  make LLVM=1 olddefconfig
  diff -u ../config .config || :

  make -s kernelrelease > version
  echo "Prepared $pkgbase version $(<version)"
}

build() {
  cd $_srcname
  make LLVM=1 V=1 -j$(nproc) all
  make LLVM=1 V=1 -j$(nproc) -C tools/bpf/bpftool vmlinux.h feature-clang-bpf-co-re=1
}

_package() {
  pkgdesc="The $pkgdesc kernel and modules"
  depends=(
    coreutils
    initramfs
    kmod
  )
  optdepends=(
    'dmemcg-booster: for cgroup-vram.patch',
    'plasma-foreground-booster-dmemcg: for cgroup-vram.patch',
    'linux-firmware: firmware images needed for some devices'
    'scx-scheds: to use sched-ext schedulers'
    'wireless-regdb: to set the correct wireless channels of your country'
  )
  provides=(
    KSMBD-MODULE
    NTSYNC-MODULE
    VIRTUALBOX-GUEST-MODULES
    WIREGUARD-MODULE
  )
  replaces=(
    virtualbox-guest-modules-arch
    wireguard-arch
  )
  cd $_srcname
  local modulesdir="$pkgdir/usr/lib/modules/$(<version)"

  echo "Installing boot image..."
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

  echo "Installing modules..."
  ZSTD_CLEVEL=19 make LLVM=1 INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 \
    DEPMOD=/doesnt/exist modules_install

  rm -f "$modulesdir"/build
}

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=(pahole)

  cd $_srcname
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  echo "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux tools/bpf/bpftool/vmlinux.h
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts
  ln -srt "$builddir" "$builddir/scripts/gdb/vmlinux-gdb.py"

  install -Dt "$builddir/tools/objtool" tools/objtool/objtool
  install -Dt "$builddir/tools/bpf/resolve_btfids" tools/bpf/resolve_btfids/resolve_btfids

  echo "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h
  install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

  echo "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  if [[ -d rust ]] && compgen -G "rust/*.rmeta" > /dev/null; then
    echo "Installing Rust files..."
    install -Dt "$builddir/rust" -m644 rust/*.rmeta
    install -Dt "$builddir/rust" rust/*.so
  fi

  echo "Installing unstripped VDSO..."
  make LLVM=1 INSTALL_MOD_PATH="$pkgdir/usr" vdso_install link=

  echo "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  echo "Removing documentation..."
  rm -r "$builddir/Documentation"

  echo "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  echo "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  echo "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -Sib "$file")" in
      application/x-sharedlib\;*)      strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  echo "Stripping vmlinux..."
  strip -v $STRIP_STATIC "$builddir/vmlinux"

  echo "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=("$pkgbase" "$pkgbase-headers")
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

# vim:set ts=8 sts=2 sw=2 et:
