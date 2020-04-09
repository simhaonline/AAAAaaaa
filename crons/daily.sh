#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREFIX="daily"
CONTAINERS="static reverseproxy mysql bukkit"

. "$ROOT_DIR/../.env"

if [[ -z "$AAAA_KEEP_LAST_DAILY" ]] || [[ -z "$AAAA_WORKING_DIRECTORY" ]] || [[ -z "$AAAA_LOGFILE" ]]; then
    >&2 echo "Missing mandatory environment variables."
    exit 1
fi

(cd "$AAAA_WORKING_DIRECTORY" && "$ROOT_DIR/../"aaaa.sh -p "$PREFIX" $CONTAINERS 2>&1 | tee -a "$AAAA_LOGFILE") && cd "$AAAA_WORKING_DIRECTORY" && for f in $(comm -3 <(ls -1 | grep "$PREFIX") <(tail -n"$AAAA_KEEP_LAST_DAILY" <(ls -1 | grep "$PREFIX"))); do rm "$f"; done
