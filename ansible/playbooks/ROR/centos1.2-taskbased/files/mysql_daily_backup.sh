#!/bin/sh
$BACKUP_FILE="`date +%Y-%m-%d`.sql.gz"
rm -rf $BACKUP_FILE
mysqldump -uroot --password={{ db_root_password }} -all-databases | gzip -9 | s3cmd put $BACKUP_FILE s3://{{ s3_backup_bucket_name }}/{{ s3_backup_path }}/$BACKUP_FILE
