#!/usr/bin/env bash
(cd /home/neo/backups && /home/neo/.aaaa/aaaa.sh -p weekly nextcloud 2>&1 | tee -a /home/neo/backups/backups.log) && cd /home/neo/backups && for f in $(comm -3 <(ls -1 | grep 'weekly') <(tail -n5 <(ls -1 | grep 'weekly'))); do rm "$f"; done
