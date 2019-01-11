#!/usr/bin/env bash

export LC_ALL=C

parent_dir="${PWD}/backups" #directory of backups
todays_dir="${parent_dir}/$(date +%F)"
log_file="${todays_dir}/backup-progress.log"
now="$(date +%m-%d-%Y_%H-%M-%S)"

# Use this to echo to standard error
error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

trap 'error "An unexpected error occurred."' ERR


set_options () {
    # List the xtrabackup arguments
    ##TODO use config file for mysql
    xtrabackup_args=(
        "--host=${HOST}"
        "--user=${MYSQL_USER}"
        "--password=${MYSQL_ROOT_PASSWORD}"
        "--backup"
        "--extra-lsndir=${todays_dir}"
        "--stream=xbstream"
	    "--compress"
    )

    backup_type="full"

    # Add option to read LSN (log sequence number) if a full backup has been
    # taken today.
    if grep -q -s "to_lsn" "${todays_dir}/xtrabackup_checkpoints"; then
        backup_type="incremental"
	    lsn=$(awk '/to_lsn/ {print $3;}' "${todays_dir}/xtrabackup_checkpoints")
        xtrabackup_args+=( "--incremental-lsn=${lsn}" )
    fi
}

rotate_old () {
    # Remove the oldest backup in rotation
    if [ -z "${DAYS}" ]; then
        day_dir_to_remove="${parent_dir}/$(date --date="${days_of_backups} days ago" +%F)"

        if [ -d "${day_dir_to_remove}" ]; then
            rm -rf "${day_dir_to_remove}"
        fi
    fi
}

take_backup () {
    # Make sure today's backup directory is available and take the actual backup
    printf "Start backup\n"
    mkdir -p "${todays_dir}"
    find "${todays_dir}" -type f -name "*.incomplete" -delete
    xtrabackup "${xtrabackup_args[@]}" --target-dir="${todays_dir}" > "${todays_dir}/${backup_type}-${now}.xbstream.incomplete" 2> "${log_file}"
    mv "${todays_dir}/${backup_type}-${now}.xbstream.incomplete" "${todays_dir}/${backup_type}-${now}.xbstream"

}

sync_backup () {
    if [ -e ~/.mc/config.json ]; then
        mc mirror --remove --overwrite "${parent_dir}"/ "${MINIO_BUCKET}"
    fi
}

set_options && take_backup && rotate_old && sync_backup

# Check success and print message
if tail -1 "${log_file}" | grep -q "completed OK"; then
    printf "Backup successful!\n"
    printf "Backup created at %s/%s-%s.xbstream\n" "${todays_dir}" "${backup_type}" "${now}"
else
    error "Backup failure! Check 'backup-progress.log' for more information"
fi
