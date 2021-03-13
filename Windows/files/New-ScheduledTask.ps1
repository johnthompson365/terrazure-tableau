$a = New-ScheduledTaskAction -Execute 'Powershell.exe' `

  -Execute "c:\\jt365\\wintab-deploy-original.ps1"

$t = New-ScheduledTaskTrigger -AtLogon
$p = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest

Register-ScheduledTask -Action $a -Trigger $t -principal $p -TaskName "Tableau Installer" -Description "Task running the Tableau powershell install script on logon" -AsJob -Force