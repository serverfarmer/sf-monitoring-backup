#!/bin/bash
. /opt/farm/scripts/init


if [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	echo "skipping backup monitoring configuration (container backups are performed by host)"
	exit 1
fi

/opt/farm/scripts/setup/extension.sh sf-cache-utils
/opt/farm/scripts/setup/extension.sh sf-monitoring-newrelic

if [ ! -s /etc/local/.config/newrelic.license ]; then
	echo "skipping backup monitoring configuration (no license key configured)"
	exit 0
fi

/opt/farm/ext/packages/utils/install.sh logtail

if ! grep -q /opt/farm/ext/monitoring-backup/cron/update.sh /etc/crontab; then
	echo "setting up crontab entry"
	echo "* * * * * root /opt/farm/ext/monitoring-backup/cron/update.sh" >>/etc/crontab
fi
