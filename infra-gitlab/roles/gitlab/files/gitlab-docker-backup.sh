#!/bin/bash
echo $(date) "Backups Gitlab configs..." >> /opt/gitlab_backup.log
docker exec -t gitlab /bin/sh -c 'umask 0077; tar -czf /var/opt/gitlab/backups/$(date "+gitlab-configs-%s.tgz") -C / etc/gitlab'&&
if [ $? -ne 0 ]; then
echo ERROR
else
echo $(date) Backups Gitlab configs... OK >> /opt/gitlab_backup.log
fi
echo $(date) "backups Gitlab..." >> /opt/gitlab_backup.log
docker exec -t gitlab gitlab-rake gitlab:backup:create
if [ $? -ne 0 ]; then
echo ERROR
else
echo $(date) Backups Gitlab... OK >> /opt/gitlab_backup.log
fi
