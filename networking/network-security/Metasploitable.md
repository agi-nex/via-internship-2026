# Metasploitable2 Exploitation Report

**Name:** Agnes Yeboah
**Index Number:** 5230160043
**Date:** 2026-09-19
**Target IP:** 192.168.100.204
**Attacker OS / Tools:** Kali Linux, Metasploit Framework, nmap 7.99

---

## Reconnaissance Summary

Confirmed connectivity to the target with `ping -c 3 192.168.100.204` (0% packet loss), then ran a full service/version scan:

```
nmap -sV -sC 192.168.100.204
```

Key findings — 23 open ports in total, including several with well-known vulnerabilities:

- **21/tcp** - vsftpd 2.3.4 (anonymous FTP allowed; known backdoor vulnerability)
- **22/tcp** - OpenSSH 4.7p1 Debian
- **23/tcp** - Telnet (Linux telnetd)
- **25/tcp** - Postfix smtpd
- **53/tcp** - ISC BIND 9.4.2
- **80/tcp** - Apache httpd 2.2.8 (Ubuntu) DAV/2
- **111/tcp** - rpcbind (NFS, mountd, nlockmgr exposed)
- **139/445/tcp** - Samba smbd 3.0.20-Debian
- **512-514/tcp** - rexec/rlogin/rsh services
- **1099/tcp** - Java RMI registry (GNU Classpath grmiregistry)
- **1524/tcp** - "Metasploitable root shell" bindshell
- **2049/tcp** - NFS
- **2121/tcp** - ProFTPD 1.3.1
- **3306/tcp** - MySQL 5.0.51a-3ubuntu5
- **5432/tcp** - PostgreSQL 8.3.0-8.3.7
- **5900/tcp** - VNC (protocol 3.3)
- **6000/tcp** - X11 (access denied)
- **6667/tcp** - UnrealIRCd (known backdoor vulnerability)
- **8009/tcp** - Apache JServ Protocol (AJP)
- **8180/tcp** - Apache Tomcat/Coyote 1.1

