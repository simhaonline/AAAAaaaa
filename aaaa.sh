#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SLAVE_DIR="$ROOT_DIR/slaves"

. "$ROOT_DIR/.env"

function main {
    d "Initializing backup sequence..."
    d "Host: $(uname -a)"

    lxc info &>/dev/null || { e "LXD not found."; exit 1; }
    tar --version &>/dev/null || { e "tar not found."; exit 1; }
    openssl version &>/dev/null || { e "openssl not found."; exit 1; }

    if [[ -z "$AAAA_PASSWORD" ]]; then
        e "AAAA_PASSWORD is blank or not set! Check your .env file."
        exit 1
    fi

    timestamp=$(date '+%Y%m%d%H%M%S')

    if [[ "$1" -eq "-p" ]]; then
        if [[ -z "$2" ]]; then
            e "Prefix not specified."
            exit 1
        fi

        master_prefix="$2"'_'
        shift 2
    fi

    args="$@"
    if [[ -z "$args" ]]; then
        args="$(ls "$SLAVE_DIR" | sed -nr 's/(.+)\.sh$/\1/p')"
    fi

    master_archive="$(hostname)_${master_prefix}${timestamp}.tar.gz"
    master_archive_encrypted="$master_archive".enc

    for arg in $args; do
        slave_container="$arg"
        slave_script="${SLAVE_DIR}/${slave_container}.sh"
        slave_archive="$(hostname)_${slave_container}_${timestamp}.tar"
        slave_archive_list="$slave_archive $slave_archive_list"

        if [[ ! -f "$slave_script" ]]; then
            e "${slave_script} does not exist."
            exit 1
        fi

        lxc info "$slave_container" &>/dev/null || { e "Container $slave_container not found."; exit 1; }

        lxc exec "$slave_container" -- id &>/dev/null
        container_is_running="$?"
        if [[ "$container_is_running" -ne 0 ]]; then
            d "Container $slave_container is not running."
            d "Starting $slave_container..."
            lxc start "$slave_container" || { e "Container $slave_container could not be started."; exit 1; }
            d "Waiting for container to be ready..."
            sleep 10
        fi

        d "${slave_container}: $slave_script $slave_archive"
        launch "$slave_container" "$slave_script" "$slave_archive"

        if [[ "$container_is_running" -ne 0 ]]; then
            d "Stopping $slave_container..."
            lxc stop "$slave_container" || { e "Container $slave_container could not be stopped."; exit 1; }
        fi
    done

    d "Compressing backups..."
    tar czvf "$master_archive" $slave_archive_list || { e "Failed to compress archives!"; exit 1; }

    d "Encrypting..."
    openssl enc -aes-256-cbc -k "$AAAA_PASSWORD" -in "$master_archive" -out "$master_archive_encrypted" || { e "Encryption process failed!"; exit 1; }

    d "Cleaning up..."
    rm -v $slave_archive_list
    rm -v "$master_archive"

    d "Great success!"

    echo "$master_archive_encrypted"
}

function launch {
    container="$1"
    script="$2"
    archive_file="$3"
    archive="/tmp/$archive_file"

    (printf "export ARCHIVE='$archive';\n"; cat "$script") | lxc exec "$container" -- bash

    if [[ $? -ne 0 ]]; then
        e "Slave $script fucked up."
        exit 1
    fi

    lxc file pull "${container}${archive}" . || { e "Could not pull tarball from container $container."; exit 1; }
    lxc exec "$container" -- rm -v "$archive" || { e "Could not remove tarball from container $container."; exit 1; }

    d "Backup for container $container written to $archive_file."
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main "$@"
