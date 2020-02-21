#!/usr/bin/env bash
(cd /home/neo/backups && /home/neo/.aaaa/aaaa.sh -p daily static reverseproxy mysql bukkit 2>&1 | tee -a /home/neo/backups/backups.log) && cd /home/neo/backups && for f in $(comm -3 <(ls -1 | grep 'daily') <(tail -n30 <(ls -1 | grep 'daily'))); do rm "$f"; done
