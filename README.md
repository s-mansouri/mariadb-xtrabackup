# mariadb-xtrabackup
Full and Incremental backup from MariaDb database with Percona XtraBackup 

Docker image with Supercronic and Minio for backup MariaDb which make full and incremental backups.

## How to use

clone this repository whenever your database exist.

### Docker:

You can use image from docker hub:

```
docker run -v /var/lib/mysql:/var/lib/mysql -v /backupdir:/mnt/backups -e HOST=mysql_host -e MYSQL_USER=root -e MYSQL_ROOT_PASSWORD=example smansoorirad/mariadb-xtrabackup
```
`backupdir` is your local directory to keeps backups

OR clone this repository, use sample/docker-compose-backup.yml.example as sample and run docker-compose

this docker-compose run a cron job which get a full backup every days and get incremental backups hourly and store backups where docker-compose run

> NOTICE: you must mount mysql datadir and a volume for backups

## Features

The `xtrabackup.sh` script has the following functionality:

- create a compressed full backup the first time it is run each day

- Generates compressed incremental backups based on the daily full backup when called again on the same day.

- Maintains backups organized by day. number of days to keep backups is set as "DAYS" environment variable. 

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
