function main {
    d "Dumping all MySQL databases..."
    mysqldump --all-databases -r backup.sql || { e "Failed to dump databases."; exit 1; }
    tar cvf "$ARCHIVE" backup.sql || { e "Could not create tarball."; exit 1; }
    rm -v backup.sql
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
