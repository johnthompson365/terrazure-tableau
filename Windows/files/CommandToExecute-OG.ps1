<#

.SYNOPSIS
Synopsis

.DESCRIPTION
Description

.PARAMETER FirstParameter
FirstParameter

.PARAMETER SecondParameter
SecondParameter

.EXAMPLE
.\script.ps1 -URL <value> -Folder <value>
#>

Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$URL,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Folder
    )
    
function Create_Folder {
    
        try {
            Write-Output "Creating the Folder named... C:\tab-deploy\"
            New-Item -Path $Folder -ItemType Directory
            Start-BitsTransfer -Source $URL -Destination $($folder+'download.exe') -TransferType Download -Priority High 
        }
        catch
        {
        Write-Error $_.Exception
        throw $_.Exception
        }
        finally
        {
        Write-Host "Did stuff..."
        $LASTEXITCODE
        }
    }
    
Create_Folder
    