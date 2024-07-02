# https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon
if(-not(query session anna.bluetenbach /server:srv)) {
  #kill process if exist
  Get-Process mstsc -IncludeUserName | Where {$_.UserName -eq "AAFABRIK\anna.bluetenbach"}|Stop-Process
  #run the command
  mstsc /v:srv
}
