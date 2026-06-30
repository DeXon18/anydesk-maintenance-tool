# AnyDesk Maintenance Toolkit

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/scripts-Batch%20%7C%20Bash-lightgrey)
![Status](https://img.shields.io/badge/status-active-success)
![Maintenance](https://img.shields.io/badge/purpose-authorized%20maintenance-orange)
![Security](https://img.shields.io/badge/security-no%20license%20bypass-red)

Maintenance scripts for authorized AnyDesk support tasks on Windows and Linux.

This toolkit is intended for basic troubleshooting scenarios where AnyDesk is installed but the service, process, cache, traces or user-side temporary files may be causing issues.

It does not modify, hide or regenerate licenses, access controls, audit data or traceability mechanisms. It can securely reset the AnyDesk ID on Windows, which helps resolve eternal wait times and connection limits caused by corrupted session states.

## Current status

| Platform | Status | Script |
|---|---|---|
| Windows | Available | `scripts/windows/anydesk-maintenance.cmd` |
| Linux | Available | `scripts/linux/anydesk-maintenance.sh` |
| macOS | Available | `scripts/macos/anydesk-maintenance.sh` |

## What this project does

- Stops the AnyDesk service or application when possible.
- Closes stuck AnyDesk processes.
- Creates a temporary backup of selected user configuration files.
- Cleans non-critical user-side temporary files, thumbnails and trace files.
- Restores the backed-up user configuration.
- Starts the AnyDesk service or application again.
- Opens AnyDesk after the maintenance process when supported.
- Saves an execution log for troubleshooting.

## What this project does not do

This toolkit is not a crack, bypass, or license reset tool.

It will not unlock paid features, remove commercial-use limits, alter licensing state, or bypass AnyDesk restrictions.

If you use AnyDesk frequently or in a professional environment, use an official AnyDesk license.

## Supported systems

- Windows
- Linux
- macOS

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

### macOS

- AnyDesk installed in `/Applications/AnyDesk.app`.
- Administrator permissions.
- Terminal access.

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
│  │  └─ anydesk-maintenance.cmd
│  ├─ linux/
│  │  └─ anydesk-maintenance.sh
│  └─ macos/
│     └─ anydesk-maintenance.sh
└─ docs/
   ├─ windows-usage.md
   ├─ linux-usage.md
   ├─ macos-usage.md
   └─ troubleshooting.md
```

## Quick start

### Windows

Open PowerShell and run:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DeXon18/anydesk-maintenance-toolkit/main/scripts/windows/anydesk-maintenance.cmd?v=$RANDOM" -OutFile "anydesk-maintenance.cmd"; (Get-Content "anydesk-maintenance.cmd") | Set-Content "anydesk-maintenance.cmd"; Start-Process "anydesk-maintenance.cmd" -Verb RunAs
```

The script will request administrator permissions before running.

### Linux

Run:

```bash
wget https://raw.githubusercontent.com/DeXon18/anydesk-maintenance-toolkit/main/scripts/linux/anydesk-maintenance.sh -O anydesk-maintenance.sh
chmod +x anydesk-maintenance.sh
sudo ./anydesk-maintenance.sh
```

### macOS

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/DeXon18/anydesk-maintenance-toolkit/main/scripts/macos/anydesk-maintenance.sh -o anydesk-maintenance.sh
chmod +x anydesk-maintenance.sh
sudo ./anydesk-maintenance.sh
```

## Manual Windows usage

1. Download the file:

```txt
scripts/windows/anydesk-maintenance.cmd
```

2. Right-click the file.
3. Select "Run as administrator".
4. Wait until the script finishes.
5. Review the log if an error appears.

## Manual Linux usage

1. Download the file:

```txt
scripts/linux/anydesk-maintenance.sh
```

2. Give execution permissions:

```bash
chmod +x anydesk-maintenance.sh
```

3. Run it as root:

```bash
sudo ./anydesk-maintenance.sh
```

## Manual macOS usage

1. Download the file:

```txt
scripts/macos/anydesk-maintenance.sh
```

2. Give execution permissions:

```bash
chmod +x anydesk-maintenance.sh
```

3. Run it as root:

```bash
sudo ./anydesk-maintenance.sh
```

## Logs

### Windows

The latest execution log is saved to:

```txt
%TEMP%\AnyDesk_Maintenance_last.log
```

### Linux and macOS

The latest execution log is saved to:

```txt
/tmp/anydesk-maintenance-last.log
```

The temporary working directory is removed at the end of the execution.

## Recommended use cases

Use this toolkit when:

- AnyDesk does not open correctly.
- The AnyDesk service is stuck.
- AnyDesk remains open in the background after closing it.
- The application behaves incorrectly after an update.
- You are experiencing connection timeouts, "wait for connection" limits, or eternal wait times due to a corrupted identity state.
- You want a repeatable support procedure with logging.

Do not use this toolkit to bypass access restrictions or modify auditing mechanisms.

## Responsible use

This toolkit does not reset licenses or usage restrictions.

It only performs maintenance tasks on service state, process state, selected user files, temporary data and logs.

Only run these scripts on machines where you have explicit permission.

## Security notice

Review the script before running it, especially if you downloaded it from the internet.

Do not execute remote scripts blindly from unknown sources.

Do not share logs publicly if they include usernames, local paths, device names or organization-specific information.

## License

This project is licensed under the MIT License.

## Disclaimer

This project is not affiliated with, endorsed by or sponsored by AnyDesk Software GmbH.

AnyDesk is a trademark of its respective owner.

These scripts are provided for authorized maintenance and troubleshooting only. Use them at your own risk.
