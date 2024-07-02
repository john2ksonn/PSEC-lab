# TODO(jso): allow multiple concurrent connections

try {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name MaxInstanceCount -Value 300 -PropertyType DWORD -Force
    New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name DisableRestrictedAdmin -Value 0

    Install-WindowsFeature -Name "Remote-Desktop-Services"
    Install-WindowsFeature -Name "RDS-Connection-Broker"
    Install-WindowsFeature -Name "RDS-RD-Server"
} catch {
        echo "RDP_PTH FAILED !!!!!!!!!!!!!!!!!!!"
}
