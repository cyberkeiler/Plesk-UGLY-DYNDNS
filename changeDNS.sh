#!/bin/bash

# Your configuration
DOMAIN="yourdomain.com"
IP_FOLDER="/var/www/vhosts/${DOMAIN}" # The Path to the files with the IP are stored!
TMP_FILE="./exists.tmp"

# Defining Colors
NOC='\033[0m'
cRED='\033[0;31m'
cOK='\033[0;32m'
cPINK='\033[0;35m'
cYEL='\033[1;33m'
COLOR9='\033[1;37m'

# To loop over arrays
ENTRIES=("A" "AAAA")

# Helper functions for printig debug and error messages
debug() {
        echo -e "${NOC}\e[7m[DEBUG] $@ ${NOC}"
}
error() {
        echo -e "${cRED}\e[7m[🚨 ERROR] $@ ${NOC}"
}

# Print Header
echo -e "${cPINK}\e[7m##################################\n##  THE UGLY DYNDNS-SCRIPT 0.2  ##\n##################################${NOC}\n"

# Info Message when no arguments passed
if [ $# -eq 0 ]; then
        error "EMPTY ARGUMENTS"
        echo -e "Please add desired subdomains as arguments\n e.g. ${cYEL}./changeDNS.sh subdomain1 subdomain2${cRED} to update ${cPINK}subdomain1.${DOMAIN}${cRED} and ${cPINK}subdomain2.${DOMAIN}.${NOC}"
fi

for SUBDOMAIN in "$@"; do
        for ENTRY in "${ENTRIES[@]}"; do
                # Create the path of IP_FILE
                IP_FILE="${IP_FOLDER}/${SUBDOMAIN}_${ENTRY}.txt"

                if [ ! -f "$IP_FILE" ]; then
                        # IP_FILE does not exist
                        error "No (IP)-File found:${cPINK} ${SUBDOMAIN}${cYEL}.${DOMAIN} ${cYEL}${COLOR9}should be in ${IP_FILE}\n"
                else
                        # read new IP
                        IP_NEW=$(cat ${IP_FILE})
                        IP_NEW_AGE=$((($(date +%s) - $(date +%s -r "${IP_FILE}")) / 60))
                        echo "false" >${TMP_FILE}
                        if (("$IP_NEW_AGE" > 20)); then
                                echo -e "${cYEL}\e[7m[WARNING] IP maybe old: ${IP_FILE} updated >${IP_NEW_AGE} minutes ago\n"
                        fi

                        # check current entries in PLESKs DNS, delete old ones and only keep those with current IP
                        /usr/local/psa/bin/dns --info ${DOMAIN} | grep "${SUBDOMAIN}.${DOMAIN}. ${ENTRY} " |
                                while IFS= read -r line; do

                                        # read IP of A/AAAA entry
                                        IP=$(echo "${line}" | cut -d " " -f 4)

                                        echo -e -n "${cPINK}${SUBDOMAIN}${cYEL}.${DOMAIN}${NOC} | ${cPINK}${ENTRY}${NOC} |  "
                                        if [ "$IP_NEW" == "$IP" ]; then
                                                echo -e "${cOK}${IP} ✅"
                                                echo "true" >${TMP_FILE}
                                                # there is an entry with current IP, so only old entries have to be deleted, but nothing to be added

                                        else
                                                echo -e -n "${cRED}${IP} - outdated 💀 => "

                                                if $(/usr/local/psa/bin/dns --del ${DOMAIN} -${ENTRY,,} $SUBDOMAIN -ip $IP); then
                                                        echo -e " ${cOK}DELETED 🗑️${NOC} "
                                                else
                                                        error "DELETING FAILED"
                                                fi

                                                debug ${RESULT}
                                        fi
                                done

                        # Replace Old IP by new IP

                        if [[ $(cat ${TMP_FILE}) = "false" ]]; then
                                echo -e -n " 🌟 New ${cPINK}${ENTRY} ${NOC} Entry required for ${cPINK}${SUBDOMAIN}${cYEL}.${DOMAIN}${NOC}: \n"

                                if /usr/local/psa/bin/dns --add ${DOMAIN} -${ENTRY,,} ${SUBDOMAIN} -ip ${IP_NEW}; then
                                        echo -e "=> ${cOK}SUCESSFULLY CREATED ✅"
                                else
                                        error "While adding ${ENTRY} entry 🚨 "
                                fi
                        fi
                        echo -e -n $NOC
                fi
        done
done
rm ${TMP_FILE}
