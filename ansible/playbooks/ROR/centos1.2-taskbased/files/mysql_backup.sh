#!/bin/bash

# ref:
# http://www.linuxbrigade.com/back-up-all-of-your-mysql-databases-nightly/
# https://fogstack.wordpress.com/2013/05/25/backup-mysql-to-s3-in-30-seconds/

DB_BACKUP="{{ log_path }}`date +%Y-%m-%d`"
DB_USER="root"
DB_PASSWD="{{ db_root_password }}"
HN=`hostname | awk -F. '{print $1}'`

# Create the backup directory
mkdir -p $DB_BACKUP

# Remove backups older than 10 days
find {{ log_path }} -maxdepth 1 -type d -mtime +{{ remove_backups_older_than_days }} -exec rm -rf {} \;

# Backup each database on the system
for db in $(mysql --user=$DB_USER --password=$DB_PASSWD -e 'show databases' -s --skip-column-names|grep -viE '(staging|performance_schema|information_schema)');
do mysqldump --user=$DB_USER --password=$DB_PASSWD --events --opt --single-transaction $db | gzip &gt; "$DB_BACKUP/mysqldump-$HN-$db-$(date +%Y-%m-%d).gz";
s3cmd put "$DB_BACKUP/mysqldump-$HN-$db-$(date +%Y-%m-%d).gz" s3://$S3_BUNDLE/$BACKUP_FILE
done

