#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom

license="`cat /etc/local/.config/newrelic.license2`"

path=`local_backup_directory`
daily=`du -sb $path/daily |cut -f1`
weekly=`du -sb $path/weekly |cut -f1`
custom=`du -sb $path/custom |cut -f1`
temp=`du --exclude daily --exclude weekly --exclude custom -sb $path/* |cut -dM -f1 |awk '{s+=$1} END {if (s>0) print s; else print 0}'`

sessions=`logtail -f/var/log/auth.log -o/var/cache/cacti/auth.offset |grep "Accepted publickey for backup from" |wc -l`

curl -s -o /dev/null https://platform-api.newrelic.com/platform/v1/metrics \
    -H "X-License-Key: $license" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -X POST -d '{
      "agent": {
        "host" : "'$HOST'",
        "version" : "0.1"
      },
      "components": [
        {
          "name": "'$HOST'",
          "guid": "org.serverfarmer.newrelic.BackupV6",
          "duration" : 60,
          "metrics" : {
            "Component/serverFarmer/backup/size/daily[bytes]": '$daily',
            "Component/serverFarmer/backup/size/weekly[bytes]": '$weekly',
            "Component/serverFarmer/backup/size/custom[bytes]": '$custom',
            "Component/serverFarmer/backup/size/temp[bytes]": '$temp',
            "Component/serverFarmer/backup/collectorSessions[Value]": '$sessions'
          }
        }
      ]
    }'
