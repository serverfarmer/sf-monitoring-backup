#!/bin/sh

if grep -q /opt/farm/ext/monitoring-backup/cron /etc/crontab; then
	echo "uninstalling deprecated sf-monitoring-backup extension"
	sed -i -e "/\/opt\/farm\/ext\/monitoring-backup\/cron/d" /etc/crontab
fi
