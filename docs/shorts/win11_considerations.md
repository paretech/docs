# Windows 11
  
## Windows 10 to 11 Transition

### Resources

- [End of support for Windows 10](https://www.microsoft.com/en-us/windows/end-of-support)
  - Windows 10 Reached end of support on October 14, 2025
- [Windows 10 Consumer Extended Security Updates (ESU)](https://www.microsoft.com/en-us/windows/extended-security-updates)
  - ESU ends on October 13, 2026
- [Windows 11 specs, features, and computer requirements](https://www.microsoft.com/en-us/windows/windows-11-specifications?r=1)
  - [compatible 64-bit processor](https://learn.microsoft.com/en-us/windows-hardware/design/minimum/windows-processor-requirements)
  - Trusted Platform Module (TPM) version 2.0.
  - Copilot+ PCs may have neural processing unit (NPU) requirements
- [Windows 11 version 25H2 Supported Intel Processors](https://learn.microsoft.com/en-us/windows-hardware/design/minimum/supported/windows-11-25h2-supported-intel-processors)
  - Minimum of Intel Core 10th Generation (i3, i5, i7, i9)
- [Windows 11 version 25H2 supported AMD processors](https://learn.microsoft.com/en-us/windows-hardware/design/minimum/supported/windows-11-25h2-supported-amd-processors)
- [System requirements for Autodesk Fusion](https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/System-requirements-for-Autodesk-Fusion-360.html#Windows)
  - Windows 11, 23H2 (Build 22631 or newer)
  - x86-64 processor 8+ performance cores, 16+ threads 3GHz+ base clock rate (e.g. Intel Core i7, AMD Ryzen 7)

### Hardware Configuration

#### Windows 10 Configuration (2016 to 2026)

- Intel Core i7-7700K @ 4.20 GHz
- ASUS PRIME Z270-A LGA Motherboard
- 32 GB (4x8) 288-Pin DDR 3200 (PC4 25600)
  - G.SKILL Ripjaws V Series (F4-3200C14D-16GVK, F4-3200C16D-16GVGB)
- Seasonic SSR-850FX 850W ATX Power Supply
- Noctua NH-D15 SSO2 D-Type CPU Cooler, NF-A15 x 2 PWM Fans

#### 2026-Present Configuration (2026 to present)

- Intel Core i7-12700KF
- MSI PRO Z690-A WIFI DDR4
- 32 GB (4x8) 288-Pin DDR 3200 (PC4 25600)
  - G.SKILL Ripjaws V Series (F4-3200C14D-16GVK, F4-3200C16D-16GVGB)
- Seasonic SSR-850FX 850W ATX Power Supply
- Noctua NH-D15 SSO2 D-Type CPU Cooler, NF-A15 x 2 PWM Fans
- Noctua NM-i17xx-MP83, Mounting Kit for Noctua CPU Coolers on Intel LGA1851 and LGA1700 
- Noctua NT-H2 3.5g, Thermal Computer Paste

## Windows 11 Configuration

- Install Firefox
- Configure task bar
- Add printer
- Enable bitlocker
- Turn off websearch
- [git](https://git-scm.com/install/windows)
  - `winget install --id Git.Git -e --source winget`, `winget upgrade Git.Git`
  - [Generate and configure keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
  - [force Git to use the system's SSH binary](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)
