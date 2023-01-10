# Plesk-Dirty-DynDNS
Dirty solution to connect a subdomain of your PLESK server to a dynamic IP automatically.

When your local NAS/Homeserver is behind an IP-changing router for example you want to push IPv4 and IPv6 changes and update the corresponding A/AAAA entries of your PLESK nameserver.

## Concept
The client calls a php script, which saves the clients IP adress to a file (one file per client/subdomain and per ipv4/ipv6).

The BASH script will read this files and check if the pushed IPs differ from those in the nameserver entries.

THen it will delete all differing entries and will only leave/create A/AAAA records with the current IP adresses.

## Installation

### PLESK Server with Nameserver
1. Upload `push_ip.php` script to a webfolder on your PLESK server (`/var/www/vhosts/${DOMAIN}/httpdocs`) or copy into an existing php script.
2. Replace subdomain1 with your subdomain and insert any random, secret token.
3. Copy `changeDNS.sh` Script anywhere on the PLESK server. e.g. in root's home folder.
4. In changeDNS.sh: Change DOMAIN (and custom IP_FOLDER if PHP-Script is at another location than `/var/www/vhosts/${DOMAIN}/httpdocs`)
5. Add cronjob to execute changeDNS.sh with desired subdomains:

```
1-59/5 * * * * ~/changeDNS.sh subdomain1 subdomain2  &> /dev/null
```   


### Client Server with dynamic IP
Create two cronjobs (one for IPv4/IPv6 each) on the Client Server to push the PLESK Server with the current client IPs:

    crontab -e

to push every 5 minutes:

```
*/5 * * * * wget -qO- --no-check-certificate --inet4-only https://yourdomain.com/push_ip.php?token=token2-991a212d21b48891bac47e997 &> /dev/null
*/5 * * * * wget -qO- --no-check-certificate --inet6-only https://yourdomain.com/push_ip.php?token=token2-991a212d21b48891bac47e997 &> /dev/null
```   
