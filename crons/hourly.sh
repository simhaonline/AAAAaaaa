#!/usr/bin/env bash
(cd /home/neo/backups && /home/neo/.aaaa/aaaa.sh -p hourly minecraft 2>&1 | tee -a /home/neo/backups/backups.log) && for f in $(comm -3 <(ls -1 | grep 'hourly') <(tail -n48 <(ls -1 | grep 'hourly'))); do rm "$f"; done
