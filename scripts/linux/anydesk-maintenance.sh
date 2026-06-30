#!/usr/bin/env bash
set -Eeuo pipefail

TITLE="AnyDesk Maintenance"
SERVICE_NAME="anydesk"
PROCESS_NAME="anydesk"

START_WAIT_LIMIT=30
STOP_WAIT_LIMIT=30

WORKDIR="$(mktemp -d /tmp/anydesk-maintenance.XXXXXX)"
LOGFILE="$WORKDIR/maintenance.log"
FINAL_LOG="/tmp/anydesk-maintenance-last.log"

TARGET_USER="${SUDO_USER:-$USER}"

if [[ "$TARGET_USER" == "root" ]]; then
    TARGET_HOME="/root"
else
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
fi

AD_USER_DIR="$TARGET_HOME/.anydesk"
AD_USER_CONF="$AD_USER_DIR/user.conf"
AD_THUMB_DIR="$AD_USER_DIR/thumbnails"

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

    if ! command -v systemctl >/dev/null 2>&1; then
        log "ERROR: systemctl was not found. This script expects a systemd-based system."
        exit 1
    fi

    if ! systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service"; then
        log "ERROR: AnyDesk service was not found."
        exit 1
    fi

    if [[ -z "$TARGET_HOME" || ! -d "$TARGET_HOME" ]]; then
        log "ERROR: target user home directory could not be resolved."
        exit 1
    fi

    log "Target user: $TARGET_USER"
    log "Target home: $TARGET_HOME"
}

stop_anydesk() {
    log "Stopping AnyDesk service."

    if systemctl is-active --quiet "$SERVICE_NAME"; then
        systemctl stop "$SERVICE_NAME" || true
    else
        log "AnyDesk service is already stopped."
    fi

    local count=0

    while systemctl is-active --quiet "$SERVICE_NAME"; do
        sleep 1
        count=$((count + 1))

        if [[ "$count" -ge "$STOP_WAIT_LIMIT" ]]; then
            log "WARNING: timeout while waiting for AnyDesk service to stop."
            break
        fi
    done

    if pgrep -x "$PROCESS_NAME" >/dev/null 2>&1; then
        log "Stopping leftover AnyDesk processes."
        pkill -x "$PROCESS_NAME" || true
        sleep 1
    else
        log "No leftover AnyDesk process found."
    fi
}

start_anydesk() {
    log "Starting AnyDesk service."

    systemctl start "$SERVICE_NAME"

    local count=0

    until systemctl is-active --quiet "$SERVICE_NAME"; do
        sleep 1
        count=$((count + 1))

        if [[ "$count" -ge "$START_WAIT_LIMIT" ]]; then
            log "ERROR: timeout while waiting for AnyDesk service to start."
            exit 1
        fi
    done

    log "AnyDesk service started successfully."
}

backup_user_config() {
    log "Creating user configuration backup."

    mkdir -p "$WORKDIR/backup_user"

    if [[ ! -d "$AD_USER_DIR" ]]; then
        log "User AnyDesk directory does not exist. Backup skipped."
        return 0
    fi

    if [[ -f "$AD_USER_CONF" ]]; then
        cp -f "$AD_USER_CONF" "$WORKDIR/backup_user/user.conf"
        log "Backup completed: user.conf"
    else
        log "user.conf does not exist. Skipped."
    fi

    if [[ -d "$AD_THUMB_DIR" ]]; then
        cp -a "$AD_THUMB_DIR" "$WORKDIR/backup_user/thumbnails"
        log "Backup completed: thumbnails"
    else
        log "Thumbnails directory does not exist. Skipped."
    fi
}

safe_cleanup() {
    log "Running safe cleanup."

    local clean_err=0

    if [[ -d "$AD_THUMB_DIR" ]]; then
        rm -rf "$AD_THUMB_DIR" || clean_err=1

        if [[ -d "$AD_THUMB_DIR" ]]; then
            log "WARNING: not all user thumbnails could be removed."
            clean_err=1
        else
            log "User thumbnails removed."
        fi
    fi

    if [[ -f "$AD_USER_DIR/ad.trace" ]]; then
        rm -f "$AD_USER_DIR/ad.trace" || clean_err=1

        if [[ -f "$AD_USER_DIR/ad.trace" ]]; then
            log "WARNING: could not remove user trace file: ad.trace"
            clean_err=1
        else
            log "User trace file removed: ad.trace"
        fi
    fi

    if [[ -f "/var/log/anydesk.trace" ]]; then
        rm -f "/var/log/anydesk.trace" || clean_err=1

        if [[ -f "/var/log/anydesk.trace" ]]; then
            log "WARNING: could not remove system trace file: /var/log/anydesk.trace"
            clean_err=1
        else
            log "System trace file removed: /var/log/anydesk.trace"
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

    mkdir -p "$AD_USER_DIR"

    if [[ -f "$WORKDIR/backup_user/user.conf" ]]; then
        cp -f "$WORKDIR/backup_user/user.conf" "$AD_USER_CONF"
        log "Restored: user.conf"
    fi

    if [[ -d "$WORKDIR/backup_user/thumbnails" ]]; then
        mkdir -p "$AD_THUMB_DIR"
        cp -a "$WORKDIR/backup_user/thumbnails/." "$AD_THUMB_DIR/"
        log "Restored: thumbnails"
    fi

    chown -R "$TARGET_USER:$TARGET_USER" "$AD_USER_DIR" 2>/dev/null || true
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
