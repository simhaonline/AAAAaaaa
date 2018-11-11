function main {
    d "Saving nginx and letsencrypt files..."
    tar cvf "$ARCHIVE" /etc/nginx /etc/letsencrypt || { e "Something went south."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
