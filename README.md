# linux-mauri870

This is my custom linux kernel config and patches, mainly used on my personal gaming machine.

- Bleeding edge Linux (Torvalds mainline tree)
- Patches
  - [HDMI FRL (for 4k@144hz, HDMI 2.1 support for AMD GPUs)](https://github.com/mkopec/linux/tree/hdmi_frl)
  - [BORE (Burst-Oriented Response Enhancer) scheduler](https://github.com/firelzrd/bore-scheduler)
  - [LLVM Polly (polyhedral loop optimizer for better cache locality and parallelism)](https://github.com/CachyOS/kernel-patches/blob/master/7.0/misc/0001-clang-polly.patch)
  - [Lazy RSS stat percpu counters (faster fork/exec for single-threaded tasks)](https://lore.kernel.org/lkml/20251127233635.4170047-2-krisman@suse.de/)
- `PREEMPT_FULL`
- `NO_HZ_FULL`
- `sched_ext`
- `TRANSPARENT_HUGEPAGE_ALWAYS`
- `NTSYNC`
- 1000 Hz tick rate
- Clang 22 + ThinLTO + `-O3` + `-march=native`

## Misc

For my 9950X3D, system tasks are restricted to CCD1 (cores 8-15), leaving CCD0 (cores 0-7, 3D V-Cache) clean for gaming:

```
GRUB_CMDLINE_LINUX_DEFAULT="isolcpus=domain,nohz,managed_irq,8-15,24-31 nohz_full=0-31 rcu_nocbs=0-31 kthread_cpus=8-15,24-31 irqaffinity=8-15,24-31"
```

## Build & Install

Compiling the kernel takes around 15-20min on a 9950X3D with the default `-j$(nproc)`.

```sh
taskset -c 0-31 makepkg -si -f
```

