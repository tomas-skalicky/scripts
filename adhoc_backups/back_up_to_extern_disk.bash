#!/usr/bin/env bash
#author      :Tomas Skalicky <skalicky.tomas@gmail.com>
#===============================================================================

set -e

#-------------------------------------------------------------------------------

set +e
read -r -d '' usage <<- EOF
	usage: ./$(basename "$0") <username> <backup_dir_name> <backup_parent_dirname>

	    username: tom, tomas,...
	    backup_dir_name: tomas_backup, tomas_check24_backup,...
	    backup_parent_dirname: 'VERBATIM HD', tomas_verbatim_hdd-backups, 'My previous HDD',...
	EOF
set -e

#-------------------------------------------------------------------------------

username=$1
backup_dir_name=$2
backup_parent_dirname=$3

#-------------------------------------------------------------------------------

if [[ -z $username ]]; then
    printf '%s\n' "$usage" >&2
    printf '%s\n' 'Missing a username argument' >&2
    exit 1
fi
if [[ -z $backup_dir_name ]]; then
    printf '%s\n' "$usage" >&2
    printf '%s\n' 'Missing a backup_dir_name argument' >&2
    exit 1
fi
if [[ -z $backup_parent_dirname ]]; then
    printf '%s\n' "$usage" >&2
    printf '%s\n' 'Missing a backup_parent_dirname argument' >&2
    exit 1
fi

#-------------------------------------------------------------------------------

assert_root_rights_presence() {
    if [[ $(whoami) != root ]]; then
        printf '%s\n' 'ERROR: This script needs to be run with root rights'
        exit 1
    fi
}

assert_root_rights_presence

#-------------------------------------------------------------------------------

backup_parent_dirpath=/media/$username/$backup_parent_dirname
if [[ ! -d $backup_parent_dirpath ]]; then
    printf "ERROR: Directory %s does not exist\n" "$backup_parent_dirpath" >&2
    exit 2
fi

#-------------------------------------------------------------------------------

backup_dir_path=$backup_parent_dirpath/$backup_dir_name
mkdir --parents "$backup_dir_path"

#-------------------------------------------------------------------------------

start_date=$(date +%Y_%m_%d__%H_%M_%S)
rsync_log_file_path=/var/log/adhoc_backup_to_extern_disk_${backup_parent_dirname}__${start_date}.rsync.log

# Immediate fail is turned on because of causes like
# "rsync warning: some files vanished before they could be transferred"
set +e

# --delete-after option means:
#     1. rsync syncs files from source (laptop disk) to destination
#        (backup folder)
#     2. When the sync is done, rsync removes from the destination
#        those files, which are no more in the source.
#
# It looks like /home/tom/.gradle/caches , /home/tom/.gradle/wrapper/dists ,
# /home/tom/.gradle/gradle/dists , /home/tom/.sdkman/archives ,
# /home/tom/.sdkman/candidates contain only
# downloaded or unpacked downloaded files.
hanka_username=hanka
rsync --archive \
      --delete-after \
      --exclude backup/ \
      --exclude cdrom/ \
      --exclude dev/ \
      --exclude home/"$username"/.cache/ \
      --exclude home/"$username"/.config/google-chrome/Default/'Service Worker'/CacheStorage/ \
      --exclude home/"$username"/.config/google-chrome/Default/'Service Worker'/ScriptCache/ \
      --exclude home/"$username"/.config/Rambox/Partitions/rambox/Cache/ \
      --exclude home/"$username"/.config/skypeforlinux/Cache/ \
      --exclude home/"$username"/.gradle/caches/ \
      --exclude home/"$username"/.gradle/gradle/dists/ \
      --exclude home/"$username"/.gradle/wrapper/dists/ \
      --exclude home/"$username"/.npm/ \
      --exclude home/"$username"/.sdkman/archives/ \
      --exclude home/"$username"/.sdkman/candidates/groovy/ \
      --exclude home/"$username"/.tldr/cache/ \
      --exclude home/"$hanka_username"/.cache/ \
      --exclude home/"$hanka_username"/.config/google-chrome/Default/'Service Worker'/CacheStorage/ \
      --exclude home/"$hanka_username"/.config/google-chrome/Default/'Service Worker'/ScriptCache/ \
      --exclude home/"$hanka_username"/.config/Rambox/Partitions/rambox/Cache/ \
      --exclude home/"$hanka_username"/.config/skypeforlinux/Cache/ \
      --exclude lost\+found/ \
      --exclude media/ \
      --exclude mnt/ \
      --exclude proc/ \
      --exclude run/ \
      --exclude sys/ \
      --exclude tmp/ \
      --exclude var/lock/ \
      --exclude var/run/ \
      --exclude var/spool/ \
      --exclude var/tmp/ \
      --log-file="$rsync_log_file_path" \
      --stats \
      --verbose \
      / \
      "$backup_dir_path"
set -e

#-------------------------------------------------------------------------------

backup_log_file_path=$backup_parent_dirpath/${backup_dir_name}__${start_date}.backup.log
printf 'SUCCESSful backup - finished at %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" \
    | tee "$backup_log_file_path"

printf '\n' >> "$backup_log_file_path"
cat "$rsync_log_file_path" >> "$backup_log_file_path"

