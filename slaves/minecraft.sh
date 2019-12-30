function main {
    #d "Stopping Minecraft server..."
    #systemctl stop minecraft.service || { e "Could not stop minecraft server."; exit 1; }

    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "say INITIATE BACKUP SEQUENCE..."\\015'

    d "Disable auto save..."
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-off"\\015'

    d "Save the world..."
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-all"\\015'
    sleep 10

    d "Create tarball..."
    tar cvf "$ARCHIVE" /home/minecraft/world /home/minecraft/*.json /home/minecraft/server.properties || { e "Could not create tarball."; screen -p 0 -S mc -X eval 'stuff "save-on"\\015'; exit 1; }

    d "Enable auto save..."
    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "save-on"\\015'

    sudo -u minecraft -- screen -p 0 -S mc -X eval 'stuff "say BACKUP SEQUENCE COMPLETE."\\015'

    #d "Starting Minecraft server..."
    #systemctl start minecraft.service || { e "Could not start minecraft server."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
