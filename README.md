# mariadb-xtrabackup
Full and Incremental backup from MariaDb database with Percona XtraBackup 

Docker image with Supercronic and Minio for backup MariaDb which make full and incremental backups.

## How to use

clone this repository whenever your database exist.

### Docker:

#### Incremental Backup
You can use image from docker hub:

```
docker run -i -v /var/lib/mysql:/var/lib/mysql -v /backupdir:/mnt/backups -e HOST=mysql_host -e MYSQL_USER=root -e MYSQL_ROOT_PASSWORD=example smansoorirad/mariadb-xtrabackup
```
`backupdir` is your local directory to keeps backups

OR
 
Clone this repository, use sample/docker-compose-backup.yml.example as sample and run docker-compose

This image run a cron job which get a full backup every days and get incremental backups hourly and store backups in `backupdir`

in case you don't need cronjob, you can run the script directly within command in docker-compose or docker run:

```
docker run -i -v /var/lib/mysql:/var/lib/mysql -v /backupdir:/mnt/backups -e HOST=mysql_host -e MYSQL_USER=root -e MYSQL_ROOT_PASSWORD=example smansoorirad/mariadb-xtrabackup bash -c ./xtrabackup.sh
```

#### Restore backup

For restore backups first the backups need extract and prepare:

```
docker run -i -v /backupdir:/mnt/backups -e RESTORE_DIR=Mon smansoorirad/mariadb-xtrabackup bash -c ./restore.sh
```
It creates restore directory inside `RESTORE_DIR`. The full-backup will represent a consistent set of data that can be moved into MariaDb's data directory.

> NOTICE: you must mount MariaDb datadir and a volume for backups

## Features

The `xtrabackup.sh` script has the following functionality:

- create a compressed full backup the first time it is run each day

- Generates compressed incremental backups based on the daily full backup when called again on the same day.

- Maintains backups organized by day. number of days to keep backups is set as "DAYS" environment variable.

When the script is run, a daily directory is created where timestamped files representing individual backups will be written. The first timestamped file will be a full backup, prefixed by full-. Subsequent backups for the day will be incremental backups, indicated by an incremental- prefix, representing the changes since the last full or incremental backup. for more information about the script see [here](https://www.digitalocean.com/community/tutorials/how-to-configure-mysql-backups-with-percona-xtrabackup-on-ubuntu-16-04#creating-the-backup-and-restore-scripts) 

The `restore.sh` script has the following functionality
 
- create a restore directory within the `backupdir` directory and then creates individual directories within for each of the backups passed in as arguments.
 
- extracting directory structure from the archive and then decompressing files.

- applies any incremental backups to the full backup to update the data with the more recent information, again applying the committed transactions.

### Sync backups with minio

for sync backups with minio mount your minio config in `/root/.mc/config.json`


### Environment Variables

**`HOST`** 

The host to use when connecting to the database server with TCP/IP

**`MYSQL_USER`**
 
the database user for more information about user privileges refer [here](https://www.percona.com/doc/percona-xtrabackup/2.4/using_xtrabackup/privileges.html#permissions-and-privileges-needed)

**`MYSQL_ROOT_PASSWORD`**

the database user's password used to connect to the server 

**`DAYS`**

number of days to keep backups

## Contributing
PRs are always welcome! Before undertaking a major change, consider opening an issue for some discussion.
