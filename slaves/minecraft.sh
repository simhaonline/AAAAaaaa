function main {
    say "Initiate backup sequence..."

    saveoff
    trap finish EXIT
    saveall

    d "Create tarball..."
    tar cvf "$ARCHIVE" /home/minecraft/world /home/minecraft/*.json /home/minecraft/server.properties

    if [[ $? != 0 ]] || [[ $? != 1 ]]; then
        e "Could not create tarball."
        say "Backup sequence incomplete. Please notify an administrator."
        exit 1
    fi

    saveon
    trap EXIT
    say "Backup sequence complete."
}

function cmd {
    sudo -u minecraft -- screen -S mc -p 0 -X stuff "$@\\015" || { e "Could not reach screen."; exit 1; }
}

function say {
    cmd "say $@"
}

function saveon {
    d "Enable auto save"
    cmd "save-on"
    sleep 30
}

function saveoff {
    d "Disable auto save"
    cmd "save-off"
    sleep 30
}

function saveall {
    d "Save world"
    cmd "save-all"
    sleep 30
}

function finish {
    saveon
    exit 1
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
