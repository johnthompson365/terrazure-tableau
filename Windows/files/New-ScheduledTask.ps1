# https://stackoverflow.com/questions/13965997/set-a-scheduled-task-to-run-when-user-isnt-logged-in
# https://sid-500.com/2017/07/26/how-to-automatically-start-powershell-at-every-logon/

$a = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass "c:\jt365\wintab-deploy-original.ps1"'    
$p = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest #-GroupId "BUILTIN\Administrators"
$t = New-ScheduledTaskTrigger -AtLogon
$s = New-ScheduledTaskSettingsSet -AsJob
$Task = New-ScheduledTask -Action $a -Principal $p -Trigger $t -Settings $s
Register-ScheduledTask -TaskName "Tableau Installer" -InputObject $Task 
#Register-ScheduledTask -Action $a -Trigger $t -principal $p -TaskName "Tableau Installer" -Description "Task running the Tableau powershell install script on logon" -AsJob -Force