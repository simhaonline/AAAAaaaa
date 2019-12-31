#!/usr/bin/env bash
cd /home/neo/backups && /home/neo/.aaaa/aaaa.sh -p daily static reverseproxy mysql minecraft >> backups.log 2>&1 && for f in $(comm -3 <(ls -1 | grep 'daily') <(tail -n30 <(ls -1 | grep 'daily'))); do rm "$f"; done
