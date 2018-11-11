function main {
    d "Stopping Minecraft server..."
    systemctl stop minecraft.service || { e "Could not stop minecraft server."; exit 1; }

    d "Saving the world..."
    tar cvf "$ARCHIVE" /home/minecraft/world || { e "Could not create tarball."; exit 1; }

    d "Starting Minecraft server..."
    systemctl start minecraft.service || { e "Could not start minecraft server."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
