function main {
    d "Saving Nextcloud files..."
    tar cvf "$ARCHIVE" /etc/nginx /etc/php /var/www/nextcloud || { e "Something went south."; exit 1; }
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
