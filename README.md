# linux-mauri870

This is my custom linux kernel config and patches, mainly used on my personal gaming machine.

- Bleeding edge Linux (Torvalds mainline tree)
- Patches
  - HDMI FRL (for 4k@144hz, HDMI 2.1 support)
  - BORE (Burst-Oriented Response Enhancer) scheduler
- `PREEMPT_FULL`
- 1000 Hz tick rate
- Clang 22 + ThinLTO + `-O3` + `-march=native`

## Build & Install

```sh
makepkg -si -f
```
