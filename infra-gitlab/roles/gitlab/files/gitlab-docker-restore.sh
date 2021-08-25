#!/bin/bash
echo $(date) "Stop All Services Gitlab..." >> /opt/gitlab_restore.log
docker exec -t gitlab gitlab-ctl stop
if [ $? -ne 0 ]; then
echo ERROR
else
echo $(date) Stop All Services Gitlab... OK >> /opt/gitlab_restore.log
fi
echo $(date) "Set the path to the folder with backups..." >> /opt/gitlab_restore.log
read gitlab_backup_path
docker exec -t gitlab-backup restore BACKUP=
if [ $? -ne 0 ]; then
echo ERROR
else
echo $(date) Stop All Services Gitlab... OK >> /opt/infra-gitlab/gitlab_restore.log
fi
