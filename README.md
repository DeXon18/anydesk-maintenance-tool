# AnyDesk Maintenance Toolkit

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/scripts-Batch%20%7C%20Bash-lightgrey)
![Status](https://img.shields.io/badge/status-active-success)
![Maintenance](https://img.shields.io/badge/purpose-authorized%20maintenance-orange)
![Security](https://img.shields.io/badge/security-no%20license%20bypass-red)

Maintenance scripts for authorized AnyDesk support tasks on Windows and Linux.

This toolkit is intended for basic troubleshooting scenarios where AnyDesk is installed but the service, process, cache, traces or user-side temporary files may be causing issues.

It does not reset, modify, hide or regenerate AnyDesk IDs, licenses, access controls, audit data or traceability mechanisms.

## Current status

| Platform | Status | Script |
|---|---|---|
| Windows | Available | `scripts/windows/anydesk-maintenance.bat` |
| Linux | Available | `scripts/linux/anydesk-maintenance.sh` |
| macOS | Not planned | N/A |

## What this project does

- Stops the AnyDesk service when possible.
- Closes stuck AnyDesk processes.
- Creates a temporary backup of selected user configuration files.
- Cleans non-critical user-side temporary files, thumbnails and trace files.
- Restores the backed-up user configuration.
- Starts the AnyDesk service again.
- Opens AnyDesk after the maintenance process.
- Saves an execution log for troubleshooting.

## What this project does not do

This toolkit is not a crack, bypass, license reset tool or ID reset tool.

It will not unlock paid features, remove commercial-use limits, alter licensing state, bypass AnyDesk restrictions or change the device identity.

If you use AnyDesk frequently or in a professional environment, use an official AnyDesk license.

## Supported systems

- Windows
- Linux

macOS support is not included.

## Requirements

### Windows

- AnyDesk installed.
- Administrator permissions.
- PowerShell or Command Prompt.
- Windows service access.

### Linux

- AnyDesk installed.
- `sudo` permissions.
- `systemd` based distribution recommended.

## Repository structure

```txt
anydesk-maintenance-toolkit/
├─ README.md
├─ LICENSE
├─ CHANGELOG.md
├─ SECURITY.md
├─ .gitignore
├─ scripts/
│  ├─ windows/
│  │  └─ anydesk-maintenance.bat
│  └─ linux/
│     └─ anydesk-maintenance.sh
└─ docs/
   ├─ windows-usage.md
   ├─ linux-usage.md
   └─ troubleshooting.md
```

## Quick start

### Windows

Run PowerShell as administrator:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DeXon18/anydesk-maintenance-toolkit/main/scripts/windows/anydesk-maintenance.bat" -OutFile "$env:TEMP\anydesk-maintenance.bat"
Start-Process "$env:TEMP\anydesk-maintenance.bat" -Verb RunAs
```

Replace `YOUR_USER` with your GitHub username or organization.

### Linux

Linux support is planned. Once available, the script will be executed with:

```bash
wget https://raw.githubusercontent.com/DeXon18/anydesk-maintenance-toolkit/main/scripts/linux/anydesk-maintenance.sh
chmod +x anydesk-maintenance.sh
sudo ./anydesk-maintenance.sh
```

## Manual Windows usage

1. Download the file:

```txt
scripts/windows/anydesk-maintenance.bat
```

2. Right-click the file.
3. Select "Run as administrator".
4. Wait until the script finishes.
5. Review the log if an error appears.

## Logs

On Windows, the latest execution log is saved to:

```txt
%TEMP%\AnyDesk_Maintenance_last.log
```

The temporary working directory is removed at the end of the execution.

## Recommended use cases

Use this toolkit when:

- AnyDesk does not open correctly.
- The AnyDesk service is stuck.
- AnyDesk remains open in the background after closing it.
- The application behaves incorrectly after an update.
- You need a controlled restart during a support session.
- You want a repeatable support procedure with logging.

Do not use this toolkit to bypass licensing, usage limits, identity checks or access restrictions.

## Responsible use

This toolkit does not reset AnyDesk IDs, licenses or usage restrictions.

It only performs maintenance tasks on service state, process state, selected user files, temporary data and logs.

Only run these scripts on machines where you have explicit permission.

## Security notice

Review the script before running it, especially if you downloaded it from the internet.

Do not execute remote scripts blindly with `curl | bash` or similar commands.

Do not share logs publicly if they include usernames, local paths, device names or organization-specific information.

## License

This project is licensed under the MIT License.

## Disclaimer

This project is not affiliated with, endorsed by or sponsored by AnyDesk Software GmbH.

AnyDesk is a trademark of its respective owner.

These scripts are provided for authorized maintenance and troubleshooting only. Use them at your own risk.
