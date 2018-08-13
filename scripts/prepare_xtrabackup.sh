#!/bin/bash

export LC_ALL=C

parent_dir="${PWD}/backups/${RESTORE_DIR}/restore" #directory of backups
shopt -s nullglob
incremental_dirs=( "${parent_dir}"/incremental-*/ )
full_dirs=( "${parent_dir}"/full-*/ )
shopt -u nullglob

log_file="${parent_dir}/prepare-progress.log"
full_backup_dir="${full_dirs[0]}"

# Use this to echo to standard error
error() {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

trap 'error "An unexpected error occurred.  Try checking the \"${log_file}\" file for more information."' ERR

do_backup () {
    # Apply the logs to each of the backups
    printf "Initial prep of full backup %s\n" "${full_backup_dir}"
    xtrabackup --prepare --apply-log-only --target-dir="${full_backup_dir}"

    for increment in "${incremental_dirs[@]}"; do
        printf "Applying incremental backup %s to %s\n" "${increment}" "${full_backup_dir}"
        xtrabackup --prepare --apply-log-only --incremental-dir="${increment}" --target-dir="${full_backup_dir}"
    done

    printf "Applying final logs to full backup %s\n" "${full_backup_dir}"
    xtrabackup --prepare --target-dir="${full_backup_dir}"
}

do_backup > "${log_file}" 2>&1
echo 1+"${do_backup}"
# Check the number of reported completions.  Each time a backup is processed,
# an informational "completed OK" and a real version is printed.  At the end of
# the process, a final full apply is performed, generating another 2 messages.
ok_count="$(grep -c 'completed OK' "${log_file}")"

if (( ${ok_count} == ${#full_dirs[@]} + ${#incremental_dirs[@]} + 1 )); then
    cat << EOF
Backup looks to be fully prepared.  Please check the "prepare-progress.log" file
to verify before continuing.

If everything looks correct, you can apply the restored files.

First, stop MariaDb and move or remove the contents of the MariaDb data directory:

Then, recreate the data directory and  copy the backup files

Afterward the files are copied, adjust the permissions and restart the service
EOF
else
    error "It looks like something went wrong.  Check the prepare-progress.log file for more information."
fi
