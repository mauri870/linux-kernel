# linux-mauri870

Custom Linux kernel tuned for gaming on dual-CCD AMD X3D processors. The X3D CCD run tickless to minimize jitter while frequency cores handle interrupts at 1000Hz tickrate. Built with Clang/ThinLTO and patched with BORE scheduling, BBR3 TCP congestion control, and various desktop-focused tweaks.

- Linux v7.0
- Patches
  - `drm:` [HDMI FRL (for 4k@144hz, HDMI 2.1 support for AMD GPUs)](https://github.com/mkopec/linux/tree/hdmi_frl)
  - `sched:` [BORE (Burst-Oriented Response Enhancer) scheduler](https://github.com/firelzrd/bore-scheduler)
  - `compiler:` [LLVM Polly (polyhedral loop optimizer for better cache locality and parallelism)](https://github.com/CachyOS/kernel-patches/blob/master/7.0/misc/0001-clang-polly.patch)
  - `mm:` [Lazy RSS stat percpu counters (faster fork/exec for single-threaded tasks)](https://lore.kernel.org/lkml/20251127233635.4170047-2-krisman@suse.de/)
  - `compiler:` CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE uses -O3
  - `x86:` Disable Split Lock mitigation
  - `net:` [Google's BBR3 for TCP congestion control](https://github.com/google/bbr/tree/v3)
  - `time:` [tick/nohz: Fix wrong NOHZ idle CPU state](https://lore.kernel.org/lkml/20260203-fix-nohz-idle-v1-1-ad05a5872080@os.amperecomputing.com/)
  - `drm/ttm:` [VRAM pressure: keep protected workloads in VRAM when GPU memory runs low](https://pixelcluster.github.io/VRAM-Mgmt-fixed/)
  - `iommu:` enable posted MSI by default (lower PCIe interrupt latency for GPU)
  - `sched:` more aggressive idle load balancing (halved avg_idle threshold)
  - `mm:` raise default max_map_count to INT_MAX (prevents game crashes from VMA exhaustion)
  - `net:` increase default socket buffer size by 4x
  - `sched:` rate-limit `sched_yield` to once per jiffy (fixes Proton/Wine games that spam yield)
  - `mm:` place shared libraries below PIE binary in address space (better code/library cache locality)
  - `mm:` use `mmput_async` on process exit (avoids blocking mm teardown under memory pressure)
  - `time:` reduce default `timer_slack_ns` from 50µs to 50ns (tighter hrtimer coalescing window for nanosleep/select/futex; inherited by all processes from PID 1)
- Config
  - `PREEMPT_FULL`
  - `NO_HZ_FULL` for tickless
  - `sched_ext`
  - `TRANSPARENT_HUGEPAGE_MADVISE`
  - `NTSYNC`
  - 1000 Hz tick rate
  - LLVM/Clang 22 + ThinLTO + `-march=native`

## Build & Install

Compiling the kernel takes around 15-20min on a 9950X3D with the default `-j$(nproc)`.

```sh
makepkg -si -f
```

## Kernel Boot Args

For dual-CCD asymmetric CPUs such as 9950X3D/9900X3D, configure the [kernel boot args](https://wiki.archlinux.org/title/Kernel_parameters) so X3D cores run tickless and offload RCU callbacks and IRQs to CCD1:

```bash
C=$(nproc); Q=$((C/4)); H=$((C/2)); echo "nohz_full=1-$((Q-1)),${H}-$((H+Q-1)) rcu_nocbs=1-$((Q-1)),${H}-$((H+Q-1)) irqaffinity=${Q}-$((H-1)),$((H+Q))-$((C-1))"
# cpu 0 can't be tickless
nohz_full=1-7,16-23 rcu_nocbs=1-7,16-23 irqaffinity=8-15,24-31
```

For a 9950X3D2 I advise to set CCD1 cores as nohz_full and move system tasks to CCD0. Since cpu0 is the BSP it cannot be made tickless, so you might as well isolate CCD1 for gaming instead.

