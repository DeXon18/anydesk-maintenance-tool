@echo off
setlocal EnableExtensions EnableDelayedExpansion

title AnyDesk Maintenance

:: ==================================================
:: Administrator permission check
:: ==================================================
fltmc >nul 2>&1 || (
    echo This script must be run as administrator.
    pause
    exit /b 1
)

:: ==================================================
:: Configuration
:: ==================================================
set "AD_SERVICE=AnyDesk"
set "AD_PROC=AnyDesk.exe"

set "AD_PROGRAM_X64=%ProgramFiles%\AnyDesk\AnyDesk.exe"
set "AD_PROGRAM_X86=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"

set "AD_SYSTEM_DIR=%ALLUSERSPROFILE%\AnyDesk"
set "AD_USER_DIR=%APPDATA%\AnyDesk"

set "WORKDIR=%TEMP%\AnyDesk_Maintenance_%RANDOM%%RANDOM%"
set "LOGFILE=%WORKDIR%\maintenance.log"
set "FINAL_LOG=%TEMP%\AnyDesk_Maintenance_last.log"

set "START_WAIT_LIMIT=30"
set "STOP_WAIT_LIMIT=30"

mkdir "%WORKDIR%" >nul 2>&1
if not exist "%WORKDIR%" (
    echo ERROR: could not create the temporary working directory.
    pause
    exit /b 1
)

echo ==========================================
echo AnyDesk Maintenance
echo Temporary directory: "%WORKDIR%"
echo ==========================================
echo.

call :log "AnyDesk maintenance started."

:: ==================================================
:: Initial validations
:: ==================================================
if not exist "%AD_SYSTEM_DIR%" (
    call :log "System directory does not exist: %AD_SYSTEM_DIR%"
)

if not exist "%AD_USER_DIR%" (
    call :log "User directory does not exist: %AD_USER_DIR%"
)

:: ==================================================
:: Stop AnyDesk
:: ==================================================
call :stop_any
if errorlevel 1 (
    call :log "AnyDesk could not be stopped correctly."
    goto cleanup_error
)

:: ==================================================
:: Controlled user configuration backup
:: ==================================================
call :backup_user_config
if errorlevel 1 (
    call :log "User configuration backup failed. Aborting to prevent data loss."
    goto cleanup_error
)

:: ==================================================
:: Reset Identity
:: ==================================================
call :reset_identity
if errorlevel 1 (
    call :log "Identity reset failed."
    goto cleanup_error
)

:: ==================================================
:: Generate New ID
:: ==================================================
call :start_any
if errorlevel 1 (
    call :log "AnyDesk could not be started to generate new ID."
    goto cleanup_error
)

call :wait_new_id
if errorlevel 1 (
    call :log "Timeout waiting for new AnyDesk ID."
    goto cleanup_error
)

:: ==================================================
:: Stop AnyDesk again to restore settings
:: ==================================================
call :stop_any

:: ==================================================
:: Restore user configuration
:: ==================================================
call :restore_user_config
if errorlevel 1 (
    call :log "User configuration could not be restored from backup."
    goto cleanup_error
)

:: ==================================================
:: Start AnyDesk (Final)
:: ==================================================
call :start_any
if errorlevel 1 (
    call :log "AnyDesk could not be started correctly."
    goto cleanup_error
)

echo.
echo ==========================================
echo Maintenance completed successfully.
echo ==========================================
echo.

goto cleanup_ok


:: ==================================================
:: USER CONFIGURATION BACKUP
:: ==================================================
:backup_user_config
call :log "Creating user configuration backup."

if not exist "%AD_USER_DIR%" (
    call :log "User directory does not exist. Backup skipped."
    exit /b 0
)

mkdir "%WORKDIR%\backup_user" >nul 2>&1
if not exist "%WORKDIR%\backup_user" (
    call :log "ERROR: could not create backup directory."
    exit /b 1
)

if exist "%AD_USER_DIR%\user.conf" (
    copy /y "%AD_USER_DIR%\user.conf" "%WORKDIR%\backup_user\user.conf" >nul 2>&1
    if errorlevel 1 (
        call :log "ERROR: could not copy user.conf to backup."
        exit /b 1
    )
    call :log "Backup completed: user.conf"
) else (
    call :log "user.conf does not exist. Skipped."
)

if exist "%AD_USER_DIR%\thumbnails" (
    robocopy "%AD_USER_DIR%\thumbnails" "%WORKDIR%\backup_user\thumbnails" /e /r:2 /w:2 /np /nfl /ndl >nul 2>&1
    if errorlevel 8 (
        call :log "ERROR: robocopy failed while backing up thumbnails. Code: %errorlevel%."
        exit /b 1
    )
    call :log "Backup completed: thumbnails"
) else (
    call :log "Thumbnails directory does not exist. Skipped."
)

exit /b 0


:: ==================================================
:: RESET IDENTITY
:: ==================================================
:reset_identity
call :log "Removing configuration to reset ID."

if exist "%AD_SYSTEM_DIR%" (
    del /f /a /q "%AD_SYSTEM_DIR%\*" >nul 2>&1
)

if exist "%AD_USER_DIR%" (
    del /f /a /q "%AD_USER_DIR%\*" >nul 2>&1
    if exist "%AD_USER_DIR%\thumbnails" rd /s /q "%AD_USER_DIR%\thumbnails" >nul 2>&1
)

exit /b 0

:: ==================================================
:: WAIT FOR NEW ID
:: ==================================================
:wait_new_id
call :log "Waiting for new AnyDesk ID to be generated..."

set /a lic_count=0

:wait_lic
find "ad.anynet.id=" "%AD_SYSTEM_DIR%\system.conf" >nul 2>&1
if not errorlevel 1 (
    call :log "New ID generated successfully."
    exit /b 0
)

timeout /t 1 >nul
set /a lic_count+=1

if !lic_count! lss %START_WAIT_LIMIT% goto wait_lic

exit /b 1


:: ==================================================
:: RESTORE USER CONFIGURATION
:: ==================================================
:restore_user_config
call :log "Restoring user configuration."

if not exist "%WORKDIR%\backup_user" (
    call :log "No backup found. Restore skipped."
    exit /b 0
)

if not exist "%AD_USER_DIR%" (
    mkdir "%AD_USER_DIR%" >nul 2>&1
    if not exist "%AD_USER_DIR%" (
        call :log "ERROR: could not create user directory."
        exit /b 1
    )
)

if exist "%WORKDIR%\backup_user\user.conf" (
    copy /y "%WORKDIR%\backup_user\user.conf" "%AD_USER_DIR%\user.conf" >nul 2>&1
    if errorlevel 1 (
        call :log "ERROR: could not restore user.conf."
        exit /b 1
    )
    call :log "Restored: user.conf"
)

if exist "%WORKDIR%\backup_user\thumbnails" (
    robocopy "%WORKDIR%\backup_user\thumbnails" "%AD_USER_DIR%\thumbnails" /e /r:2 /w:2 /np /nfl /ndl >nul 2>&1
    if errorlevel 8 (
        call :log "ERROR: robocopy failed while restoring thumbnails. Code: %errorlevel%."
        exit /b 1
    )
    call :log "Restored: thumbnails"
)

exit /b 0


:: ==================================================
:: START ANYDESK
:: ==================================================
:start_any
call :log "Starting AnyDesk service."

sc query "%AD_SERVICE%" >nul 2>&1
if errorlevel 1 (
    call :log "AnyDesk service does not exist."
    exit /b 1
)

sc query "%AD_SERVICE%" | find /i "RUNNING" >nul 2>&1
if not errorlevel 1 (
    call :log "AnyDesk service is already running."
    goto open_any
)

sc start "%AD_SERVICE%" >nul 2>&1

set /a count=0

:wait_start
sc query "%AD_SERVICE%" | find /i "RUNNING" >nul 2>&1
if not errorlevel 1 (
    call :log "AnyDesk service started successfully."
    goto open_any
)

timeout /t 1 >nul
set /a count+=1

if !count! lss %START_WAIT_LIMIT% goto wait_start

call :log "Timeout while waiting for AnyDesk service to start."
exit /b 1


:open_any
call :log "Searching for AnyDesk executable."

if exist "%AD_PROGRAM_X64%" (
    call :log "Opening AnyDesk from Program Files."
    start "" "%AD_PROGRAM_X64%"
    exit /b 0
)

if exist "%AD_PROGRAM_X86%" (
    call :log "Opening AnyDesk from Program Files x86."
    start "" "%AD_PROGRAM_X86%"
    exit /b 0
)

call :log "ERROR: AnyDesk.exe was not found in the expected paths."
exit /b 1


:: ==================================================
:: STOP ANYDESK
:: ==================================================
:stop_any
call :log "Stopping AnyDesk service."

sc query "%AD_SERVICE%" >nul 2>&1
if errorlevel 1 (
    call :log "AnyDesk service does not exist. Attempting to close process."
    goto kill_proc
)

sc query "%AD_SERVICE%" | find /i "STOPPED" >nul 2>&1
if not errorlevel 1 (
    call :log "AnyDesk service is already stopped."
    goto kill_proc
)

sc stop "%AD_SERVICE%" >nul 2>&1

set /a count=0

:wait_stop
sc query "%AD_SERVICE%" | find /i "STOPPED" >nul 2>&1
if not errorlevel 1 (
    call :log "AnyDesk service stopped successfully."
    goto kill_proc
)

timeout /t 1 >nul
set /a count+=1

if !count! lss %STOP_WAIT_LIMIT% goto wait_stop

call :log "Timeout while waiting for AnyDesk service to stop."

:kill_proc
tasklist /fi "imagename eq %AD_PROC%" | find /i "%AD_PROC%" >nul 2>&1
if not errorlevel 1 (
    taskkill /f /im "%AD_PROC%" >nul 2>&1
    call :log "Orphaned AnyDesk process detected and terminated."
) else (
    call :log "No running AnyDesk process found."
)

exit /b 0


:: ==================================================
:: LOG
:: ==================================================
:log
echo [%date% %time%] %~1
if exist "%WORKDIR%" echo [%date% %time%] %~1>>"%LOGFILE%"
exit /b 0


:: ==================================================
:: CLEANUP
:: ==================================================
:cleanup_ok
call :log "Process completed successfully."
call :purge_workdir
echo Log saved to: "%FINAL_LOG%"
echo.
echo Exiting automatically in 3 seconds...
timeout /t 3 >nul
exit /b 0


:cleanup_error
call :log "Process completed with errors."
call :purge_workdir
echo.
echo The process completed with errors.
echo Log saved to: "%FINAL_LOG%"
echo.
pause
exit /b 1


:: ==================================================
:: TEMPORARY WORK DIRECTORY CLEANUP
:: Copies the log outside the working directory before deleting it.
:: ==================================================
:purge_workdir
if exist "%LOGFILE%" (
    copy /y "%LOGFILE%" "%FINAL_LOG%" >nul 2>&1
)

if exist "%WORKDIR%" (
    rd /s /q "%WORKDIR%" >nul 2>&1
)

exit /b 0
