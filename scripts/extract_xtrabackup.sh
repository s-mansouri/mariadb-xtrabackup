#!/bin/bash

export LC_ALL=C

log_file="extract-progress.log"
number_of_args="${#}"
processors="$(nproc --all)"
dir="${PWD}/backups/${RESTORE_DIR}"

# Use this to echo to standard error
error () {
    printf "%s: %s\n" "$(basename "${BASH_SOURCE}")" "${1}" >&2
    exit 1
}

trap 'error "An unexpected error occurred.  Try checking the \"${log_file}\" file for more information."' ERR

do_extraction () {
echo "${@}"
    for file in "${@}"; do

        base_filename="$(basename "${file%.xbstream}")"
        restore_dir="/${dir}/restore/${base_filename}"

        printf "\n\nExtracting file %s\n\n" "${file}"

        # Extract the directory structure from the backup file
        mkdir --verbose -p "${restore_dir}"
        xbstream -x -C "${restore_dir}" < "${file}"

        xtrabackup_args=(
            "--parallel=${processors}"
            "--decompress"
	    )

        xtrabackup "${xtrabackup_args[@]}" --target-dir="${restore_dir}"
        find "${restore_dir}" -name "*.xbcrypt" -exec rm {} \;
        find "${restore_dir}" -name "*.qp" -exec rm {} \;

        printf "\n\nFinished work on %s\n\n" "${file}"

    done > "${log_file}" 2>&1
}

do_extraction "$@"

ok_count="$(grep -c 'completed OK' "${log_file}")"

# Check the number of reported completions.  For each file, there is an
# informational "completed OK".  If the processing was successful, an
# additional "completed OK" is printed. Together, this means there should be 2
# notices per backup file if the process was successful.
if (( $ok_count !=  $# )); then
    error "It looks like something went wrong. Please check the \"${log_file}\" file for additional information"
else
    printf "Extraction complete! Backup directories have been extracted to the \"restore\" directory.\n"
fi
