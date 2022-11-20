#!/usr/bin/env bash
#author      :Tomas Skalicky <skalicky.tomas@gmail.com>
#===============================================================================

# see
# https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar

#-------------------------------------------------------------------------------

username=tom

#-------------------------------------------------------------------------------

# shellcheck disable=SC2034
user_full_name='Tomas Skalicky'
# shellcheck disable=SC2034
user_email=skalicky.tomas@gmail.com
# shellcheck disable=SC2034
bash_utilities_file_path=$(pwd)/../../../../bash/util/utilities

#-------------------------------------------------------------------------------

main() {
    source ../shared/constants/common_constants
    source ../shared/constants/dropbox_constants
    source ../../../../bash/util/utilities
    source ../../../../python/util/utilities
    source ../../../util/python_linux_utilities
    source ../../../util/xserver_utilities
    source ../../util/debian_family_utilities
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    prepare_and_set_user_folders "$username"
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    source ../shared/roles/secured_functions
    source ../shared/roles/base
    source ../shared/roles/snap
    source ../shared/roles/jvm_software_development_kit java 17.0.5-tem
    source ../shared/roles/jvm_software_development_kit groovy
    source ../shared/roles/jvm_software_development_kit maven
    source ../shared/roles/gradle "${user_home:?}"/Documents/development/gradle
    source ../shared/roles/node
    source ../shared/roles/intellij_idea IC
    source ../shared/roles/pycharm community
    source ../shared/roles/git
    source ../shared/roles/docker
    source ../shared/roles/rambox
    # Needed for video calls which rambox cannot serve yet.
    source ../shared/roles/skype
    source ../shared/roles/xserver
    source ../shared/roles/pass
    source ../shared/roles/virtualbox
    source roles/private_laptop
    source ../shared/roles/search
    print_info 'Setup has been successful'
}

#-------------------------------------------------------------------------------

main
