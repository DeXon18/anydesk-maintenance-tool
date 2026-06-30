#!/usr/bin/env bash
set -Eeuo pipefail

TITLE="AnyDesk Maintenance"
APP_PATH="/Applications/AnyDesk.app"
PROCESS_NAME="AnyDesk"

START_WAIT_LIMIT=30
STOP_WAIT_LIMIT=30

WORKDIR="$(mktemp -d /tmp/anydesk-maintenance.XXXXXX)"
LOGFILE="$WORKDIR/maintenance.log"
FINAL_LOG="/tmp/anydesk-maintenance-last.log"

TARGET_USER="${SUDO_USER:-$USER}"

if [[ "$TARGET_USER" == "root" ]]; then
    TARGET_HOME="/var/root"
else
    TARGET_HOME="$(dscl . -read "/Users/$TARGET_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
fi

CONFIG_DIR="$TARGET_HOME/Library/Application Support/AnyDesk"
USER_CONF="$CONFIG_DIR/user.conf"
THUMB_DIR="$CONFIG_DIR/thumbnails"

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOGFILE"
}

cleanup_workdir() {
    if [[ -f "$LOGFILE" ]]; then
        cp -f "$LOGFILE" "$FINAL_LOG" 2>/dev/null || true
    fi

    if [[ -d "$WORKDIR" ]]; then
        rm -rf "$WORKDIR"
    fi
}

finish_ok() {
    log "Process completed successfully."
    cleanup_workdir
    echo
    echo "Maintenance completed successfully."
    echo "Log saved to: $FINAL_LOG"
    exit 0
}

finish_error() {
    local exit_code=$?
    log "Process completed with errors. Exit code: $exit_code"
    cleanup_workdir
    echo
    echo "The process completed with errors."
    echo "Log saved to: $FINAL_LOG"
    exit "$exit_code"
}

trap finish_error ERR

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "This script must be run as root. Use sudo."
        exit 1
    fi
}

check_environment() {
    log "Checking environment."

    if [[ ! -d "$APP_PATH" ]]; then
        log "ERROR: AnyDesk.app was not found at $APP_PATH."
        exit 1
    fi

    if [[ -z "${TARGET_HOME:-}" || ! -d "$TARGET_HOME" ]]; then
        log "ERROR: target user home directory could not be resolved."
        exit 1
    fi

    log "Target user: $TARGET_USER"
    log "Target home: $TARGET_HOME"
    log "Config directory: $CONFIG_DIR"
}

stop_anydesk() {
    log "Stopping AnyDesk application."

    osascript -e 'tell application "AnyDesk" to quit' >/dev/null 2>&1 || true

    local count=0

    while pgrep -x "$PROCESS_NAME" >/dev/null 2>&1; do
        sleep 1
        count=$((count + 1))

        if [[ "$count" -ge "$STOP_WAIT_LIMIT" ]]; then
            log "WARNING: AnyDesk did not quit within timeout. Terminating process."
            pkill -x "$PROCESS_NAME" || true
            sleep 1
            break
        fi
    done

    if pgrep -x "$PROCESS_NAME" >/dev/null 2>&1; then
        log "WARNING: AnyDesk process is still running after termination attempt."
    else
        log "AnyDesk application stopped."
    fi
}

start_anydesk() {
    log "Starting AnyDesk application."

    open "$APP_PATH"

    local count=0

    until pgrep -x "$PROCESS_NAME" >/dev/null 2>&1; do
        sleep 1
        count=$((count + 1))

        if [[ "$count" -ge "$START_WAIT_LIMIT" ]]; then
            log "ERROR: timeout while waiting for AnyDesk to start."
            exit 1
        fi
    done

    log "AnyDesk application started successfully."
}

backup_user_config() {
    log "Creating user configuration backup."

    mkdir -p "$WORKDIR/backup_user"

    if [[ ! -d "$CONFIG_DIR" ]]; then
        log "AnyDesk user configuration directory does not exist. Backup skipped."
        return 0
    fi

    if [[ -f "$USER_CONF" ]]; then
        cp -f "$USER_CONF" "$WORKDIR/backup_user/user.conf"
        log "Backup completed: user.conf"
    else
        log "user.conf does not exist. Skipped."
    fi

    if [[ -d "$THUMB_DIR" ]]; then
        cp -a "$THUMB_DIR" "$WORKDIR/backup_user/thumbnails"
        log "Backup completed: thumbnails"
    else
        log "Thumbnails directory does not exist. Skipped."
    fi
}

safe_cleanup() {
    log "Running safe cleanup."

    local clean_err=0

    if [[ -d "$THUMB_DIR" ]]; then
        rm -rf "$THUMB_DIR" || clean_err=1

        if [[ -d "$THUMB_DIR" ]]; then
            log "WARNING: not all user thumbnails could be removed."
            clean_err=1
        else
            log "User thumbnails removed."
        fi
    fi

    if [[ -f "$CONFIG_DIR/ad.trace" ]]; then
        rm -f "$CONFIG_DIR/ad.trace" || clean_err=1

        if [[ -f "$CONFIG_DIR/ad.trace" ]]; then
            log "WARNING: could not remove user trace file: ad.trace"
            clean_err=1
        else
            log "User trace file removed: ad.trace"
        fi
    fi

    return "$clean_err"
}

restore_user_config() {
    log "Restoring user configuration."

    if [[ ! -d "$WORKDIR/backup_user" ]]; then
        log "No backup found. Restore skipped."
        return 0
    fi

    mkdir -p "$CONFIG_DIR"

    if [[ -f "$WORKDIR/backup_user/user.conf" ]]; then
        cp -f "$WORKDIR/backup_user/user.conf" "$USER_CONF"
        log "Restored: user.conf"
    fi

    if [[ -d "$WORKDIR/backup_user/thumbnails" ]]; then
        mkdir -p "$THUMB_DIR"
        cp -a "$WORKDIR/backup_user/thumbnails/." "$THUMB_DIR/"
        log "Restored: thumbnails"
    fi

    chown -R "$TARGET_USER:staff" "$CONFIG_DIR" 2>/dev/null || true
}

main() {
    echo "=========================================="
    echo "$TITLE"
    echo "Temporary directory: $WORKDIR"
    echo "=========================================="
    echo

    log "AnyDesk maintenance started."

    require_root
    check_environment
    stop_anydesk
    backup_user_config

    if ! safe_cleanup; then
        log "Cleanup did not complete fully. Continuing, but review the log."
    fi

    restore_user_config
    start_anydesk
    finish_ok
}

main "$@"
