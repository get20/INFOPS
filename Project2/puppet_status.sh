#!/bin/bash

for STAT in $(sudo cat /var/lib/puppet/state/last_run_summary.yaml | grep fail | awk '{print $2}')
do
        if [ "$STAT" -gt 0 ]
        then
                echo "Last puppet run did not finish without errors."
                exit 2
        fi
done

echo "Last puppet run successful."
exit 0
