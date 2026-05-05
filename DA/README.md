# WIP

# Dolby Vision Enabler for Unsupported Monitors on Windows (LLDV EDID Spoofing)

This guide explains how to enable true **Low-Latency Dolby Vision (LLDV)** on standard SDR or basic HDR10 monitors (e.g., 300 nits VA/IPS panels) on Windows 11.
By default, Dolby Vision is restricted to certified devices via encrypted ICC profiles and hardware EDID tags. By spoofing the EDID and using a Windows Registry override, we can force the GPU (Player-led LLDV) to do the heavy lifting. The GPU will process the Dolby Vision metadata, tone-map it perfectly to your monitor's actual peak brightness, and send a standard HDR signal to your screen.
No washed-out colors, no crushed blacks, no blown-out highlights!

## 🧠 How It Works (The Science)
1. **LLDV (Player-Led Dolby Vision):** Instead of the monitor decoding Dolby Vision, we tell Windows that the monitor only supports "Low-Latency" mode. This forces the GPU (NVIDIA/AMD/Intel) to decode the Dolby Vision signal and do the tone mapping.
2. **EDID Spoofing:** We inject a custom **Dolby Vendor-Specific Video Data Block (VSVDB)** into your monitor's firmware memory (EDID) using CRU and AW EDID Editor.
3. **Registry Override (`EDRMaxLuminance`):** Standard Dolby Vision profiles assume you have an 400+ nits display. If you apply that to a 300 nits monitor, highlights will clip. We use a Windows Media Foundation registry hack to hard-limit the OS tone mapping to exactly **300 nits**.

## 🛠️ Prerequisites
* **Windows 10 / 11** (with HDR enabled in Display Settings).

* [HEVC Video Extensions][HEVCVideoExtensions]
* [Dolby Vision Extensions][DolbyVisionExtensions]
* [Dolby Vision][DolbyVision]
* [CRU][CRU]
* [AW EDID Editor][AWEDIDEditor]
* [dvfw.netlify.app][dvfw.netlify.app]
---

## 🚀 Step-by-Step Guide

### Step 1: Free up EDID Space
*The Dolby Vision block requires 12 bytes of memory. Most monitors don't have free space in their EDID, so we need to delete useless data.*

1. Open **CRU.exe** as Administrator.
2. Select your active monitor from the top dropdown list.
3. In the lower **Extension blocks** section, select `CTA-861` and click **Edit**.
4. In the **Data blocks** section, find **TV resolutions** (it usually takes 15 bytes) and click **Delete**. (Your 1440p/4K PC monitor does not need ancient TV resolutions).
5. You should now see `(18 bytes left)`. Click **OK** to close the Extension Block window.
6. Click **Export...** (bottom left) and save the file to your Desktop as `monitor.bin`.

### Step 2: Inject the Dolby Vision Block
1. Open **AW EDID Editor**.
2. Go to `File -> Open` and load your `monitor.bin`.
3. On the left sidebar, expand **CEA Extension**.
4. Click the `Add new CEA Block` dropdown and select **Vendor-Specific Video**.
5. On the right panel, set the **IEEE OUI** to `53318` (or select *Dolby Laboratories* / `00 D0 46`).
6. In the **Payload (HEX String)** box, paste the following custom LLDV payload:
text
   ```
   480347825e6d95
   ```
   *(**Note:** This specific HEX is mathematically calculated for a **~320 nits** peak brightness display. See the "Payload Breakdown" section below for details).*
7. Go to `File -> Save As...` and save it to your Desktop as `monitor_dv.bin`.

### Flash the Modded EDID
1. Open **CRU.exe** again.
2. Click **Import...** (bottom left) and select your new `monitor_dv.bin` file.
3. Click **OK** to close CRU.
4. In the CRU folder, run `restart64.exe`. Your screen will flicker black a few times as the GPU driver restarts and reads the new Dolby Vision EDID.

### The 300-Nits Registry Hack
To prevent Dolby Vision from over-brightening the image and causing highlight clipping on a 300-nit monitor, we must tell the Windows Media Foundation API to cap the tone mapping at 300 nits.

Open **Command Prompt (CMD)** or **PowerShell** as Administrator and run these two commands:

cmd
```
REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Media Foundation\SVR" /f
REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Media Foundation\SVR" /v EDRMaxLuminance /t REG_DWORD /d 300 /f
```
*(If your monitor is brighter, e.g., HDR400, change `300` to `400`).*
Restart your PC to ensure all changes take effect.

---

## 🎬 Testing & Verification
Dolby Vision on Windows **only works through the official Windows Media Foundation API**.
Third-party players like VLC, MPC-HC, or PotPlayer **will NOT work** (they will fall back to HDR10 or show purple/green tinted colors).

1. Ensure **HDR** is turned ON in Windows Display Settings.
2. Open the native Windows **Movies & TV** app and play a local Dolby Vision `.mp4` file, OR open the official **Netflix** app.

---

## 🔍 Payload Breakdown (For Geeks)
Where did `480347825e6d95` come from?

This is a Dolby VSVDB (Version 2) payload based on the LG C1 profile, but heavily modified for low-nits monitors.
* `48`     : Version bits and DM bits.
* `03`     : Minimum luminance (0.005 nits).
* `47`     : This controls the Target Max PQ (Brightness). `0x47` corresponds to Dolby's PQ Index **8**. According to the SMPTE ST-2084 PQ curve, Index 8 equals exactly **320.26 cd/m² (nits)**. This perfectly matches a standard 300-nit PC monitor without severe clipping.
* `82`     : Interface Mode. This bit forces **Standard + Low-Latency (LLDV)** mode, commanding the GPU to handle the tone-mapping.
* `5e6d95` : Color primaries (Rx, Ry, Gx, Gy, Bx, By). This matches ~100% sRGB / ~85% DCI-P3, which is the physical limit of most standard VA/IPS panels.



1. Make sure you are using the official Netflix App or the "Movies & TV" app. Browsers (Chrome/Edge) do not support the Windows DV API.
2. Because we forced the `LLDV` flag in the EDID, the desktop GPU takes over the processing. It bypasses the old laptop requirement of needing an Intel iGPU to handle the Dolby Vision license.



[HEVCVideoExtensions]:   https://apps.microsoft.com/detail/9nmzlz57r3t7
[DolbyVisionExtensions]: https://apps.microsoft.com/detail/9pltg1lwphlf
[DolbyVision]:           https://apps.microsoft.com/detail/9mvmz93n61t9
[CRU]:                   https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU
[AWEDIDEditor]:          https://www.analogway.com/products/aw-edid-editor
[dvfw.netlify.app]:      https://dvfw.netlify.app
