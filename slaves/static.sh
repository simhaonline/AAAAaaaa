function main {
    d "Saving static websites..."
    tar cvf "$ARCHIVE" /etc/nginx /home/static || { e "Something went south."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
