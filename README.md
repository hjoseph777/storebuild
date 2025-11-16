name=README.md url=https://github.com/hjoseph777/storebuild/blob/main/README.md
# StoreBuild (GoldStoreBuildBeta5)

Author: Harry Joseph
Script: GoldStoreBuildBeta5.au3
Language: AutoIt v3
Last known update: 2017 (see header comments in script)

## Purpose / Overview
StoreBuild is an AutoIt-based GUI tool to automate provisioning and personalization of point-of-sale (POS) systems. The script provides a guided GUI for configuring registers (Fixed vs Tablet), setting IP addressing (static or DHCP), installing and configuring POS components and peripheral printers (Epson/Samsung), running personalization installers (Oracle Retail, pinpad personalize script), and performing housekeeping tasks such as network cache clearing and module deployment.

It is intended for use by system engineers/technicians to quickly configure POS hardware and software following a standardized process.

## High-level features
- Single-instance enforcement to avoid concurrent runs
- Admin privilege requirement (#RequireAdmin)
- Graphical UI with selectable POS type (Fixed / Tablet), training toggle, and register selector
- Progress and timer display; activity and error logging
- IP discovery and static IP assignment flows
- DHCP activation flow for wireless/tablet POS
- POS name personalization and running external installers (Oracle Retail installer, pinpad personalize script)
- Printer setup flows including Epson (receipt) and Samsung front/back printers (some flows are placeholders in this version)
- Automatic installation of helper files into a DataStorage folder
- Expiry check (script includes an expiry guard)
- COM error handling and event logging
- Optional reboot countdown on exit

## Important referenced files / dependencies
Files referenced by the script (must be present or provided via FileInstall):
- DataStorage/SetModules.bat
- DataStorage/RepairNetwork.cmd
- DataStorage/HostNWGroup.cmd
- Temp: NewRetail1.txt (placed via FileInstall)
- Expected installers on Desktop:
  - "POS Client Installer.exe" (Oracle Retail installer)
  - "Personalize.cmd" (pinpad personalize)
- Installer location expected for Epson Java POS ADK:
  - D:\Installers\EpsonJavaPosAdk\ (sDestination variable in script)
- AutoIt UDFs and includes used by the script (must be on the include path):
  - GUIExtender.au3
  - PrintMgr.au3
  - expiry.au3
  - log.au3
  - CSVSplit.au3
  - Standard AutoIt UDFs (File, Array, Date, String, GuiListView, etc.)

## Notable global settings & registry keys
- Registry key read: `HKEY_CURRENT_USER\Software\StoreBuild` value `epsonkey2` — used as an Epson-installed flag
- HKLM root chosen by OS architecture detection: uses `HKLM64` when running on x64 OS

## Main UI flows
- Select POS type:
  - Fixed: runs Fixedpos() which:
    - Discovers IP info, sets static IPs, adds POS name, installs/configures printers (Epson/Samsung), personalizes POS by running Oracle installer, optionally updates pinpad.
  - Tablet/Wireless: runs Wireless() which:
    - Discovers IP info, activates DHCP, adds POS name, runs Oracle installer, configures tablet-specific printers.
- Training toggle: switches between live and training RIAB lists and affects IP/register choices
- Register selector: populates a combo of register IDs based on selected mode

## Key functions (non-exhaustive)
- Fixedpos() — main provisioning flow for Fixed POS
- Wireless() — main provisioning flow for Tablet/Wireless POS
- SearchIPInfo(), RetreivingIPInfo(), AddStaticIPInfo() — IP discovery and application
- AddPOSname(), Personalize() — apply POS name and run installer scripts
- AddEpson(), AddSamsungFrontPrinter(), AddSamsungBackPrinter() — peripherals setup (some calls are commented/placeholders in this version)
- ActivateDhcp() — enable DHCP for wireless mode
- AddEpsonSilentFiles() — support files for silent Epson install
- _Log_Report(), _Log_Open(), _Log_Close() and _ErrFunc() — logging and error handling
- _expire() — script expiry guard

## Known/observed behaviors & caveats
- The script uses FileInstall to embed some helper files; when compiling or running from source, ensure those targets exist or are adjusted.
- Several printer-related functions are present but commented-out or left as placeholders in this version.
- Some hard-coded paths/locations (D:\ installers, Desktop file names) are assumed and should be adapted for different environments.
- The script enforces Admin privileges and uses registry and network changes — run only on intended machines and with backups.
- Script includes an expiry check, which will disable execution after a configured date (see _expire call).

## Running the script / prerequisites
1. Run as Administrator (AutoIt #RequireAdmin in header).
2. Ensure referenced installers and DataStorage helper files are present or packaged via FileInstall if compiling.
3. Ensure the AutoIt includes/UDFs referenced (GUIExtender.au3, PrintMgr.au3, expiry.au3, log.au3, CSVSplit.au3) are available in the include path.
4. Launch GoldStoreBuildBeta5.au3 and use the GUI to:
   - Choose POS type (Fixed or Tablet)
   - Toggle Training if needed
   - Enter store number and select register
   - Click Start to run provisioning
5. Monitor progress via GUI and Temp log file created under %TEMP% (StoreBuild<date>.log)

## Security & Safety
- The script performs system-level operations (network, registry, software install), so only run in controlled/trusted environments.
- Back up current network and registry configurations before running on production hardware.
- Verify installer signatures and sources for Oracle Retail, printer drivers, and pinpad software.

## Suggested next actions / TODOs
- Update paths and installer file names to be configurable (via INI or CLI arguments).
- Replace hard-coded D:\ paths with configurable destinations.
- Improve error reporting around external installer failures (capture return codes/logs).
- Unify printer setup flows, and replace commented placeholders with working implementations.
- Add a dry-run mode that logs planned actions without applying changes.
- Consider removing or parameterizing the embedded expiry for longer-term use.

## Change history (from script header)
- Multiple dated entries in 2017 documenting evolution: added print management, Epson install checks and registry keys, Java VM fixes, training & cut-over INI/registry, Vdocs & BPT automation extensions, activity logging, countdown reboot, firewall adjustments, Jarvis checks, and more.

License
- No explicit license found in this script. Add a LICENSE file if you wish to open-source or define reuse terms.
