Get-ADUser -Identity "lena.obstfeld" | Set-ADAccountControl -DoesNotRequirePreAuth:$true
