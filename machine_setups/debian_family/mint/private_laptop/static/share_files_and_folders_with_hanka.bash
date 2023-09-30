#!/usr/bin/env bash

set -e

group_name=${1:?'Provide a name of group what both Tomas and Hanka are members of, e.g. tomas_hanka'}
hankas_user_name=${2:?"Provider a name of Hanka's user, e.g. hanka"}
tomas_user_name=${3:?"Provider a name of Tomas's user, e.g. tom"}
root_folders_to_process=("${@:4}")

echo -n 'Now: '
date +"%Y-%m-%d %H:%M:%S"

for root_folder in "${root_folders_to_process[@]}"; do

    echo -e "\n# Find all non-hidden files and folders (=not starting with dot) in the folder '$root_folder' which are NOT in the user group '$group_name' and set their group to this group."
    set -x
    find "$root_folder" \
        \( -type f -or -type d \) \
        ! -path '*\/\.*' \
        ! -group "$group_name" \
        -exec echo {} \; \
        -exec chgrp "$group_name" {} \+
    set +x

    echo -e "\n# Find all non-hidden folders (=not starting with dot) in the folder '$root_folder' which are NOT readable or NOT writable for users of their group and grant them these permissions."
    set -x
    find "$root_folder" \
        -type d \
        ! -path '*\/\.*' \
        \( ! -perm /g+r -or ! -perm /g+w \) \
        -exec echo {} \; \
        -exec chmod g+rw {} \+
    set +x

    echo -e "\n# Find all non-hidden files (=not starting with dot) in the folder '$root_folder' which are owned by the user '$hankas_user_name' and are NOT readable or NOT writable for users of their group and grant them these permissions."
    set -x
    find "$root_folder" \
        -type f \
        -user "$hankas_user_name" \
        ! -path '*\/\.*' \
        \( ! -perm /g+r -or ! -perm /g+w \) \
        -exec echo {} \; \
        -exec chmod g+rw {} \+
    set +x

    echo -e "\n# Find all non-hidden files (=not starting with dot) in the folder '$root_folder' which are owned by the user '$tomas_user_name' and are NOT readable or are writable for users of their group and grant/revoke them these permissions."
    set -x
    find "$root_folder" \
        -type f \
        -user "$tomas_user_name" \
        ! -path '*\/\.*' \
        \( ! -perm /g+r -or -perm /g+w \) \
        -exec echo {} \; \
        -exec chmod g+r {} \+ \
        -exec chmod g-w {} \+
    set +x
done
