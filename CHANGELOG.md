# Changelog

All notable changes to this project will be documented in this file.

This project follows a simple versioning format:

```txt
MAJOR.MINOR.PATCH
```

## [Unreleased]

### Fixed

- Updated PowerShell one-liner in README to download script to `$env:TEMP` instead of current directory, preventing "Access Denied" errors when running without admin privileges in restricted folders.

### Planned

- Add Linux maintenance script.
- Add Linux usage documentation.
- Add troubleshooting guide.
- Add issue templates.
- Add pull request template.

## [0.1.0] - 2026-06-30

### Added

- Added AnyDesk ID reset capability to Windows script.
- Renamed Windows script from .bat to .cmd to improve PowerShell compatibility.
- Initial Windows maintenance script.
- Administrator permission check.
- AnyDesk service stop and start flow.
- Detection and termination of stuck AnyDesk processes.
- Temporary user configuration backup.
- Safe cleanup for user thumbnails and trace files.
- User configuration restore after cleanup.
- Execution logging.
- Final log copy to:

```txt
%TEMP%\AnyDesk_Maintenance_last.log
```

- Temporary working directory cleanup after execution.

### Security

- Added explicit scope limitation for authorized maintenance use only.
- Avoided license, access control, audit and traceability modifications.
- Avoided generic temporary folder cleanup outside the script working directory.

### Notes

- Windows support is available.
- Linux support is planned.
- macOS support is not included.
