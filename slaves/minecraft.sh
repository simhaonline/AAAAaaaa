function main {
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "say Initiate backup sequence..."\\015' || { e "Could not reach screen."; exit 1; }

    d "Disable auto save..."
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-off"\\015' || { e "Could not reach screen."; exit 1; }

    d "Save the world..."
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-all"\\015' || { e "Could not reach screen."; exit 1; }
    sleep 10

    d "Create tarball..."
    tar cvf "$ARCHIVE" /home/minecraft/world /home/minecraft/*.json /home/minecraft/server.properties || { e "Could not create tarball."; sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-on"\\015'; exit 1; }

    d "Enable auto save..."
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-on"\\015' || { e "Could not reach screen."; exit 1; }

    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "say Backup sequence complete."\\015' || { e "Could not reach screen."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
