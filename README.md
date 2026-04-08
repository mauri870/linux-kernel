# linux-mauri870

This is my custom linux kernel config and patches, mainly used on my personal gaming machine.

- Bleeding edge Linux (Torvalds mainline tree)
- Patches
  - HDMI FRL (for 4k@144hz, HDMI 2.1 support)
  - BORE (Burst-Oriented Response Enhancer) scheduler
  - LLVM Polly (polyhedral loop optimizer for better cache locality and parallelism)
- `PREEMPT_FULL`
- `NO_HZ_FULL`
- `sched_ext`
- `TRANSPARENT_HUGEPAGE_ALWAYS`
- `NTSYNC`
- 1000 Hz tick rate
- Clang 22 + ThinLTO + `-O3` + `-march=native`

## Build & Install

```sh
makepkg -si -f
```
