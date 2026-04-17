# linux-mauri870

This is my custom linux kernel config and patches, mainly used on my personal gaming machine.

- Linux v7.0
- Patches
  - [HDMI FRL (for 4k@144hz, HDMI 2.1 support for AMD GPUs)](https://github.com/mkopec/linux/tree/hdmi_frl)
  - [BORE (Burst-Oriented Response Enhancer) scheduler](https://github.com/firelzrd/bore-scheduler)
  - [LLVM Polly (polyhedral loop optimizer for better cache locality and parallelism)](https://github.com/CachyOS/kernel-patches/blob/master/7.0/misc/0001-clang-polly.patch)
  - [Lazy RSS stat percpu counters (faster fork/exec for single-threaded tasks)](https://lore.kernel.org/lkml/20251127233635.4170047-2-krisman@suse.de/)
  - CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE uses -O3
  - Disable Split Lock mitigation
  - [Google's BBR3 for TCP congestion control](https://github.com/google/bbr/tree/v3)
  - [tick/nohz: Fix wrong NOHZ idle CPU state](https://lore.kernel.org/lkml/20260203-fix-nohz-idle-v1-1-ad05a5872080@os.amperecomputing.com/)
  - drivers/iommu: enable posted MSI by default (lower PCIe interrupt latency for GPU)
  - sched: more aggressive idle load balancing (halved avg_idle threshold)
  - vm: raise default max_map_count to INT_MAX (prevents game crashes from VMA exhaustion)
  - net: increase default socket buffer size by 4x
  - sched: rate-limit `sched_yield` to once per jiffy (fixes Proton/Wine games that spam yield)
  - fs: place shared libraries below PIE binary in address space (better code/library cache locality)
  - kernel: use `mmput_async` on process exit (avoids blocking mm teardown under memory pressure)
  - Reverts for desktop freeze with nohz_full:
    - time: revert `check_tick_dependency()` inverted return value
    - time: revert `clockevents: Prevent timer interrupt starvation`
- `PREEMPT_FULL`
- `NO_HZ_FULL` for tickless
- `sched_ext`
- `TRANSPARENT_HUGEPAGE_ALWAYS`
- `NTSYNC`
- 1000 Hz tick rate
- LLVM/Clang 22 + ThinLTO + `-march=native`

## Build & Install

Compiling the kernel takes around 15-20min on a 9950X3D with the default `-j$(nproc)`.

```sh
makepkg -si -f
```

## Kernel Boot Args

For dual-CCD asymmetric CPUs such as 9950X3D, configure the X3D cores to run tickless and offload RCU callbacks and IRQs to CCD1:

```bash
# cpu 0 can't be tickless
nohz_full=1-7,16-23 rcu_nocbs=1-7,16-23 irqaffinity=8-15,24-31
```

