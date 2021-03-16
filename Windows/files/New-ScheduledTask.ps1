# https://stackoverflow.com/questions/13965997/set-a-scheduled-task-to-run-when-user-isnt-logged-in
# https://sid-500.com/2017/07/26/how-to-automatically-start-powershell-at-every-logon/

# $a = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass "c:\jt365\wintab-deploy-original.ps1"'    
# $p = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest #-GroupId "BUILTIN\Administrators"
# $t = New-ScheduledTaskTrigger -AtLogon
# $s = New-ScheduledTaskSettingsSet
# $Task = New-ScheduledTask -Action $a -Principal $p -Trigger $t -Settings $s
# Register-ScheduledTask -TaskName "Tableau Installer" -InputObject $Task 
#Register-ScheduledTask -Action $a -Trigger $t -principal $p -TaskName "Tableau Installer" -Description "Task running the Tableau powershell install script on logon" -AsJob -Force

# https://www.powershellgallery.com/packages/WindowsImageConverter/1.0/Content/Set-RunOnce.ps1
function Set-RunOnce
  <#
      .SYNOPSIS
      Sets a Runonce-Registry Key
 
      .DESCRIPTION
      Sets a Runonce-Key in the Computer-Registry. Every Program which will be added will run once at system startup.
      This Command can be used to configure a computer at startup.
 
      .EXAMPLE
      Set-Runonce -command '%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file c:\Scripts\start.ps1'
      Sets a Key to run Powershell at startup and execute C:\Scripts\start.ps1
 
      .NOTES
      Author: Holger Voges
      Version: 1.0
      Date: 2018-08-17
 
      .LINK
      https://www.netz-weise-it.training/
  #>
{
    [CmdletBinding()]
    param
    (
        #The Name of the Registry Key in the Autorun-Key.
        [string]
        $KeyName = 'RunTabInstall',

        #Command to run
        [string]
        $Command = '%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -executionpolicy bypass -file C:\jt365\wintab-deploy-original.ps1'
  
    ) 

    
    if (-not ((Get-Item -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce).$KeyName ))
    {
        New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name $KeyName -Value $Command -PropertyType ExpandString
    }
    else
    {
        Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name $KeyName -Value $Command -PropertyType ExpandString
    }
}
Set-RunOnce