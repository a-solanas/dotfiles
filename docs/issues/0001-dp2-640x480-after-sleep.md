# Secondary monitor locks at 640x480 after sleep/wake

**Status:** resolved (workaround)

## Problem

After an idle session (sleep or DPMS blank), DP-2 comes back stuck at 640x480 4:3
and cannot be changed via KDE Display Settings or kscreen-doctor. Only DP-1 is
unaffected.

## Root cause

On wake, the GPU brings the DisplayPort link back up before the monitor is fully
awake. The EDID read over the AUX channel returns garbage — specifically, colorimetry
values KWin rejects:

```
kwin_wayland: EDID colorimetry xy(0.330078, 0.297852) xy(0.597656, 0.149414) ... is invalid
```

With no valid EDID, KWin discards the monitor's real capabilities and falls back to
a minimal VGA mode list (640x480 and a handful of sub-640 modes). `xrandr` shows
`0mm x 0mm` for DP-2, confirming the physical dimensions weren't read either.

The NVIDIA suspend/resume services (`nvidia-suspend.service` etc.) being disabled is
not the cause — they are intentionally irrelevant here. This system runs
**nvidia-open** (open kernel modules, 610.43.02), which uses the kernel's native
DRM/KMS power management. Those services call `nvidia-sleep.sh`, which immediately
exits when `/proc/driver/nvidia/suspend` is absent (open-module behaviour by design).

## Workaround (applied)

Physically unplug and re-plug the DP-2 cable. This forces a clean EDID read and
restores full resolution without a reboot.

## Permanent fix (pending)

Force-load a saved EDID so the kernel never relies on the post-wake AUX read:

1. After a clean boot (before any sleep), capture the good EDID:
   ```
   sudo cat /sys/class/drm/card1-DP-2/edid > /tmp/dp2-edid.bin
   sudo mkdir -p /lib/firmware/edid
   sudo cp /tmp/dp2-edid.bin /lib/firmware/edid/dp2.bin
   ```
2. Add kernel parameter to bootloader:
   ```
   drm.edid_firmware=DP-2:edid/dp2.bin
   ```
3. Regenerate initramfs: `sudo mkinitcpio -P`
