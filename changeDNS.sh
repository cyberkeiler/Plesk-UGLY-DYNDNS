# Your configuration
IPPATH="/var/yourIPfolder" # The Path to the files with the IP are stored!
DOMAIN="yourdomain.com"

# Defining Colors
NOC='\033[0m'
RED='\033[0;31m'
COLOR2='\033[0;35m'
COLOR1='\033[1;33m'
COLOR9='\033[1;37m'

echo -e  "${COLOR2}##################################\n##  THE UGLY DYNDNS-SCRIPT 0.1  ##\n##################################${NOC}"


for SUBDOMAIN in "$@"
do
        # The Path to the IP files
        FILE_NEW="${IPPATH}/${SUBDOMAIN}_NEWIP.txt"
        FILE_OLD="${IPPATH}/${SUBDOMAIN}_OLDIP.txt"

        if [ !  -f "$FILE_NEW" ]
                then printf "${RED}ERROR!!!${COLOR1} IP File for ${COLOR2}${SUBDOMAIN}${COLOR1}.${DOMAIN} ${COLOR1}does not exist!\n - Searched for:${COLOR9} ${FILE_NEW}\n"
        else
                # Excerting the IPs out of the files
                IP_NEW=`cat ${FILE_NEW}`

                if [  -f "$FILE_OLD" ]
                        then IP_OLD=`cat ${FILE_OLD}`
                fi

                #Check if the IPs did change:
                if [ "$IP_NEW" == "$IP_OLD" ]
                        then echo -e "${COLOR1}The IP for ${COLOR2}${SUBDOMAIN}${COLOR1}.${DOMAIN}. did not change! It's still ${COLOR2}${IP_NEW} ${COLOR9}"
                else
                        if [  -f "$FILE_OLD" ]
                                then # This will delete the A Entry of the Subdomain to the old IP Adress
                                echo -e "${COLOR1}Delete linking A-Entry of ${COLOR2} ${SUBDOMAIN}.${DOMAIN} ${COLOR9}"
                                /usr/local/psa/bin/dns --del ${DOMAIN} -a $SUBDOMAIN -ip $IP_OLD
                        else
                                echo -e "${COLOR1}No OLD IP File - so I do not know any Entry to delete for ${COLOR2} ${SUBDOMAIN}.${DOMAIN} ${COLOR1}yet${COLOR9}"
                        fi

                        echo -e "${COLOR1}Recreate Linking ${COLOR2} ${SUBDOMAIN}.${DOMAIN} ${COLOR9}"
                        # Replace Old IP by new IP
                        if /usr/local/psa/bin/dns --add ${DOMAIN} -a ${SUBDOMAIN} -ip ${IP_NEW}
                                then cp $FILE_NEW $FILE_OLD
                        else
                                echo -e " - ${RED} FAILED!"
                        fi
                fi
        fi
done
