#!/usr/bin/env bash

HOSTNAME="$(hostname)"
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SLAVE_DIR="$ROOT_DIR/slaves"

function main {
    d "Initializing backup sequence..."
    d "Host: $(uname -a)"

    lxc info &>/dev/null || { e "LXD not found."; exit 1; }
    tar --version &>/dev/null || { e "tar not found."; exit 1; }

    timestamp=$(date '+%Y%m%d%H%M%S')

    for arg in "$@"; do
        slave_container="$arg"
        slave_script="${SLAVE_DIR}/${slave_container}.sh"
        slave_archive="${HOSTNAME}_${slave_container}_${timestamp}.tar"
        master_archive="${HOSTNAME}_${timestamp}.tar.gz"

        if [[ ! -f slave ]]; then
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
        fi

        d "${slave_container}: $slave_script $slave_archive"
        launch "$slave_container" "$slave_script" "$slave_archive"

        if [[ "$container_is_running" -ne 0 ]]; then
            d "Stopping $slave_container..."
            lxc stop "$slave_container" || { e "Container $slave_container could not be stopped."; exit 1; }
        fi
    done
}

function launch {
    container="$1"
    script="$2"
    archive="$3"

    cat "$script" | lxc exec "$container" -- ARCHIVE="$archive" bash
}

function d {
    echo "$(date '+%b %d %H:%M:%S') ${HOSTNAME}: $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') ${HOSTNAME}: $*"
}

main "$@" # bash magic
