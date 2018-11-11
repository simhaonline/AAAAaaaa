function main {
    d "Dumping all MySQL databases..."
    for db in $(mysql -e 'show databases' --skip-column-names --batch | grep -v '^\(information_schema\|performance_schema\|sys\)$'); do

        mysqldump --databases "$db" -r "$db.sql" || { e "Failed to dump database $db."; exit 1; }

        files="$db.sql $files"
    done

    tar cvf "$ARCHIVE" $files || { e "Could not create tarball."; exit 1; }
    rm -v $files
}

function d {
    echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

function e {
    >&2 echo "$(date '+%b %d %H:%M:%S') $(hostname): $*"
}

main
