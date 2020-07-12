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
    source ../../../util/xserver_utilities
    source ../../util/debian_family_utilities
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    prepare_and_set_user_folders "$username"
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    source ../shared/roles/secured_functions
    source ../shared/roles/base
    source ../shared/roles/openjdk
    source ../shared/roles/jvm_software_development_kit groovy
    source ../shared/roles/jvm_software_development_kit maven
    source ../shared/roles/gradle "${user_home:?}"/Documents/development/gradle
    source ../shared/roles/node
    source ../shared/roles/eclipse
    source ../shared/roles/intellij_idea IC
    source ../shared/roles/pycharm community
    source ../shared/roles/tomcat
    source ../shared/roles/git
    source ../shared/roles/docker
    source ../shared/roles/oracle_xe
    source ../shared/roles/rambox
    # Needed for video calls which rambox cannot serve yet.
    source ../shared/roles/skype
    source ../shared/roles/xserver
    source ../shared/roles/pass
    source ../shared/roles/virtualbox
    source ../shared/roles/elasticsearch
    source ../shared/roles/kibana
    local -r logstash_forwarder_cert_file_path=/etc/pki/tls/certs/logstash-forwarder.crt
    source roles/logstash_forwarder__private_laptop "$logstash_forwarder_cert_file_path"
    source ../shared/roles/logstash_forwarder "$logstash_forwarder_cert_file_path"
    source ../shared/roles/ledger_wallet
    source roles/private_laptop
    # Moved at the end of the list of roles because an upgrade of Python
    # packages takes time.
    source ../shared/roles/python
    source ../shared/roles/search
    print_info 'Setup has been successful'
}

#-------------------------------------------------------------------------------

main

