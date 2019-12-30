function main {
    say "Initiate backup sequence..."

    d "Disable auto save and save world..."
    cmd "save-off"
    cmd "save-all"
    sleep 10

    d "Create tarball..."
    tar cvf "$ARCHIVE" /home/minecraft/world /home/minecraft/banned-ips.json /home/minecraft/banned-players.json /home/minecraft/ops.json /home/minecraft/whitelist.json /home/minecraft/server.properties || { e "Could not create tarball."; cmd "save-on"; say "Backup sequence incomplete. Please notify an administrator."; exit 1; }
    sync

    d "Enable auto save..."
    cmd "save-on"

    say "Backup sequence complete."
}

function cmd {
    sudo -u minecraft -- screen -S mc -p 0 -X stuff "$@\\015" || { e "Could not reach screen."; exit 1; }
}

function say {
    cmd "say $@"
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
