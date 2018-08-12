# mariadb-xtrabackup
Full and Incremental backup from MariaDb database with Percona XtraBackup 

Docker image with Supercronic and Minio for backup MariaDb which make full and incremental backups.

## How to use

clone this repository whenever your database exist.

### Docker:

You can use image from docker hub:

```
docker pull smansoorirad/mariadb-xtrabackup
```

OR clone this repository, use sample/docker-compose-backup.yml.example as sample and run docker-compose

this docker-compose run a cron job which get a full backup every days and get incremental backups hourly and store backups where docker-compose run

> NOTICE: you must mount mysql datadir and a volume for backups
## Features

The `xtrabackup.sh` script has the following functionality:

- create a compressed full backup the first time it is run each day

- Generates compressed incremental backups based on the daily full backup when called again on the same day.

- Maintains backups organized by day. number of days to keep backups is set as "DAYS" environment variable. 

## Contributing
PRs are always welcome! Before undertaking a major change, consider opening an issue for some discussion.
