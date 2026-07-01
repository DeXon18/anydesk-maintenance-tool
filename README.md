# AnyDesk Maintenance Toolkit

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/scripts-Batch%20%7C%20Bash-lightgrey)
![Status](https://img.shields.io/badge/status-active-success)
![Last Commit](https://img.shields.io/github/last-commit/DeXon18/Anydesk-Maintenance-Tool)
![Repo Size](https://img.shields.io/github/repo-size/DeXon18/Anydesk-Maintenance-Tool)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

Maintenance scripts for AnyDesk support tasks on Windows, Linux, and macOS.

This toolkit is intended for basic troubleshooting scenarios where AnyDesk is installed but the service, processes, cache, or temporary files are causing issues.

### 🔄 Reset AnyDesk Free License (ID)

The primary feature of the Windows script is securely resetting the AnyDesk ID. This removes the block that prevents connections to other devices after continuous use, effectively resolving "eternal wait times" and connection limits.

> [!WARNING]
> **Important:** This is not a crack. The goal is to restore the functionality of the free version within the limitations of the application itself. It does not permanently unlock AnyDesk, nor does it modify real licenses, access controls, or traceability mechanisms. It simply allows you to use the free version again without interruptions.

> [!TIP]
> We strongly recommend purchasing an official license if you intend to use AnyDesk frequently or in a professional environment.

---

## ⚡ Quick Start

### Windows

The fastest way to resolve eternal wait times or connection limits on Windows is via this one-liner. Open PowerShell as Administrator and run:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DeXon18/Anydesk-Maintenance-Tool/main/scripts/windows/anydesk-maintenance.cmd?v=$RANDOM" -OutFile "$env:TEMP\anydesk-maintenance.cmd"; (Get-Content "$env:TEMP\anydesk-maintenance.cmd") | Set-Content "$env:TEMP\anydesk-maintenance.cmd"; Start-Process "$env:TEMP\anydesk-maintenance.cmd" -Verb RunAs
```

### Linux / macOS

_For Unix-based platforms, download the shell scripts via `wget` or `curl` and run them with `sudo`. See the [Manual Usage](#manual-usage) section for more details._

---

## 📑 Table of Contents

- [What this project does](#what-this-project-does)
- [What this project does not do](#what-this-project-does-not-do)
- [Manual Usage](#manual-usage)
- [Logs](#logs)
- [Recommended use cases](#recommended-use-cases)
- [Responsible use](#responsible-use)

---

## 🛠️ What this project does

- Stops the AnyDesk service or application when possible.
- Closes stuck AnyDesk processes.
- Creates a temporary backup of selected user configuration files.
- Cleans non-critical user-side temporary files, thumbnails and trace files.
- Restores the backed-up user configuration.
- Starts the AnyDesk service or application again.
- Opens AnyDesk after the maintenance process when supported.
- Saves an execution log for troubleshooting.

## 🚫 What this project does not do

This toolkit is not a crack, bypass, or license reset tool.

It will not unlock paid features, remove commercial-use limits, alter licensing state, or bypass AnyDesk restrictions. If you use AnyDesk frequently or in a professional environment, use an official AnyDesk license.

---

## 💻 Manual Usage

<details>
<summary><strong>Windows</strong></summary>

1. Download the file: `scripts/windows/anydesk-maintenance.cmd`
2. Right-click the file and select "Run as administrator".
3. Wait until the script finishes.
4. Review the log if an error appears.

</details>

<details>
<summary><strong>Linux</strong></summary>

```bash
wget https://raw.githubusercontent.com/DeXon18/Anydesk-Maintenance-Tool/main/scripts/linux/anydesk-maintenance.sh -O anydesk-maintenance.sh
chmod +x anydesk-maintenance.sh
sudo ./anydesk-maintenance.sh
```

</details>

<details>
<summary><strong>macOS</strong></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/DeXon18/Anydesk-Maintenance-Tool/main/scripts/macos/anydesk-maintenance.sh -o anydesk-maintenance.sh
chmod +x anydesk-maintenance.sh
sudo ./anydesk-maintenance.sh
```

</details>

---

## 📄 Logs

> [!TIP]
> The temporary working directory is removed automatically at the end of the execution, but the final log is preserved for review.

**Windows:** The latest execution log is saved to `%TEMP%\AnyDesk_Maintenance_last.log`
**Linux / macOS:** The latest execution log is saved to `/tmp/anydesk-maintenance-last.log`

---

## 🎯 Recommended use cases

Use this toolkit when:

- You are experiencing connection timeouts, "wait for connection" limits, or eternal wait times due to a corrupted identity state.
- AnyDesk does not open correctly.
- The AnyDesk service is stuck.
- AnyDesk remains open in the background after closing it.
- The application behaves incorrectly after an update.
- You want a repeatable support procedure with logging.

> [!WARNING]
> Do not use this toolkit to bypass access restrictions or modify auditing mechanisms.

## ⚖️ Responsible use

This toolkit does not reset licenses or usage restrictions. It only performs maintenance tasks on service state, process state, selected user files, temporary data and logs. Only run these scripts on machines where you have explicit permission.

Review the script before running it, especially if you downloaded it from the internet. Do not execute remote scripts blindly from unknown sources.

## Disclaimer

This project is not affiliated with, endorsed by or sponsored by AnyDesk Software GmbH. AnyDesk is a trademark of its respective owner. These scripts are provided for authorized maintenance and troubleshooting only. Use them at your own risk.
