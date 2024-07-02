# Source URL
$url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64.zip"
# Destation file
$dest = "c:\tmp\OpenSSH-Win64.zip"
# Download the file
Invoke-WebRequest -Uri $url -OutFile $dest

Unblock-File $dest
Expand-Archive $dest -DestinationPath . -Force
try {
    Copy-Item -Recurse .\OpenSSH-Win64\ 'C:\' -Force
    &icacls C:\OpenSSH-Win64\libcrypto.dll /grant Everyone:RX
    C:\OpenSSH-Win64\install-sshd.ps1
    &sc.exe config sshd start= auto
    &sc.exe config ssh-agent start= auto
    &sc.exe start sshd
    &sc.exe start ssh-agent

    New-ItemProperty `
      -Path "HKLM:\SOFTWARE\OpenSSH" `
      -Name DefaultShell `
      -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
      -PropertyType String `
      -Force

    New-NetFirewallRule `
      -Name sshd `
      -DisplayName 'OpenSSH SSH Server' `
      -Enabled True `
      -Direction Inbound `
      -Protocol TCP `
      -Action Allow `
      -LocalPort 22 `
      -Program "C:\OpenSSH-Win64\sshd.exe"
} catch {
    # Just silently fail 
    # TODO(jso): this might be awful
    exit 0
}
