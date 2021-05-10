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
            Write-Output 'Creating the Folder named..'
            New-Item -Path '${replace(Folder, "'", "''")}' -ItemType Directory
            Start-BitsTransfer -Source '${replace(URL, "'", "''")}' -Destination $($folder+'download.exe') -TransferType Download -Priority High 
        }
    catch
        {
        Write-Error $_.Exception
        throw $_.Exception
        }
    finally
        {
        Write-Host 'Did stuff...'
        $LASTEXITCODE
        }
    }
    
Create_Folder