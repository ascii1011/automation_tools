#!/bin/sh
$BACKUP_FILE="`date +%Y-%m-%d`.sql.gz"
rm -rf $BACKUP_FILE
mysqldump -u root -p {{ db_root_password }} --all-databases --single-transaction | gzip -9 | s3cmd put $BACKUP_FILE s3://{{ s3_backup_bucket_name }}/{{ s3_backup_path_mysql_data }}/$BACKUP_FILE
