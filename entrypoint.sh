#!/bin/sh

exec 2>&1
set -e

# Updating the Services for RUNIT
update-service  --add   /etc/sv/mysql-server  mysql-server
update-service  --add   /etc/sv/apache2       apache2
update-service  --add   /etc/sv/sshd          sshd

# Running the RUNIT Service from binary
exec /usr/bin/runsvdir -P /etc/service
