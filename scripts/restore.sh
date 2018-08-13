#!/usr/bin/env bash

parent_dir="${PWD}/backups/${RESTORE_DIR}"

if [ -z "${RESTORE_DIR}" ]; then
    echo "please specify RESTORE_DIR"
else
    echo "start extract"
    /mnt/extract_xtrabackup.sh  "${parent_dir}"/*.xbstream

    echo "start prepare"
    /mnt/prepare_xtrabackup.sh
fi