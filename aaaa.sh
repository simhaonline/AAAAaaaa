#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SLAVE_DIR="$ROOT_DIR/slaves"

function main {
    d "Initializing backup sequence..."
    d "Host: $(uname -a)"

    lxc info &>/dev/null || { e "LXD not found."; exit 1; }
    tar --version &>/dev/null || { e "tar not found."; exit 1; }

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

    for arg in $args; do
        slave_container="$arg"
        slave_script="${SLAVE_DIR}/${slave_container}.sh"
        slave_archive="$(hostname)_${slave_container}_${timestamp}.tar"
        slave_archive_list="$slave_archive $slave_archive_list"
        master_archive="$(hostname)_${master_prefix}${timestamp}.tar.gz"

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
    tar czvf "$master_archive" $slave_archive_list

    rm -v $slave_archive_list

    d "Great success!"

    echo "$master_archive"
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
