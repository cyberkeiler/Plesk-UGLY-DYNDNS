# Plesk-Dirty-DynDNS
dirty solution to connect subdomain to dynamic IPs

## Installation
1. Place the php file in your Webfolder or add it to a homepage of your choice
2. Insert the Path to a desired IP-Folder under $path
3. Place the sh Script anywhere and let a Cronjob execute it in the frequency of your choice.
4. Change Folder and Domainname in the .SH File

## IP updates
Let a cronjob etc. call the PHP file with the Token as a GET (do it with HTTPS!)

    wget -qO- --no-check-certificate https://yourdomain.com/save-new-ip.php?token=token2-991a212d21b48891bac47e997 &> /dev/null
    
## DNS updates
Let a cronjob etc. call the Bash Script with the subdomain names as arguments

    ./changeDNS.sh subdomain1 subdomain2
