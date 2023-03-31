# PowerShell Template
# Author: Tomas Kadlec, info@tomkadlec.cz
# Version 0.2
# Fill variable $sPackageName line 35
#----------------------------------------
# SCRIPT AUTHOR :
# DATE          :
# DESCRIPTION   :
#----------------------------------------
#==============================================
# VARIABLES DEFINITION
#==============================================
# List all system variables > Get-Childitem -Path Env:* | Sort-Object Name
$ScriptName = $MyInvocation.MyCommand.Name
$ScriptPath = Get-Location     # C:\PathToScript
$ScriptFullPath = $MyInvocation.MyCommand.Path     # C:\PathToScript\Script.ps1
$ScriptParentFolderName = Split-Path (Get-Location) -Leaf
$WinDir = $Env:windir
$ProgramData = $Env:ProgramData     # C:\ProgramData
$ProgramFiles = $Env:ProgramFiles     # C:\Program Files
$ProgramFilesX86 = ${Env:ProgramFiles(x86)}     # C:\Program Files (x86)
$UserProfile = $HOME    # C:\Users\Username
$UserDesktop = "$UserProfile\Desktop"    # C:\Users\Username\Desktop
$UserAppData = $Env:APPDATA    # C:\Users\Username\AppData\Roaming

# Edit regarding your needs
$LogPath = $Env:SystemDrive + "\applogs"
$DateFormat = "dd.MM.yyyy HH:mm:ss"
$Now = (Get-Date -f $DateFormat)

#==============================================
# PACKAGE NAME
#==============================================

$PackageName = ""

#==============================================
# LOG FILE CONFIGURATION
#==============================================

$LogToFile = $true
$LogToCSV = $false
if ($LogToCSV) {
    $LogExt = ".csv"
} else {
    $LogExt = ".log"
}
if ($PackageName -eq "" -or $PackageName -eq $null) {
    $LogFile = $LogPath + "\" + $ScriptParentFolderName + "_" + $ScriptName + $LogExt
} else {
    $LogFile = $LogPath + "\" + $PackageName + "_" + $ScriptName + $LogExt
}

#==============================================
# FUNCTIONS
#==============================================

function LOG {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Severity = 'INFO'
    )


    if ($LogToFile) {
        if ($LogToCSV) {
            [PSCustomObject]@{
            Time = $Now
            Severity = $Severity
            Message = $Message
            } | Export-Csv -Path $LogFile -Append -NoTypeInformation
        } else {
            Add-content $LogFile -Value "$Now : $Severity : $Message"
        }
    } else {
        Write-Host "$Message - $Severity"
    }
}
LOG -Message "Start $ScriptFullPath" -Severity INFO


function MESSAGE {
    # Usage: MESSAGE "Folder $ProgramFilesX86\TestFolder created!"
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$msgBody
    )
    LOG -Message "Function MESSAGE : $msgBody" -Severity INFO
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    [System.Windows.MessageBox]::Show($msgBody)
}


function RUN {
    # Usage: RUN "$WinDir\notepad.exe"
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [string]$RunParameters
    )

    if (Test-Path -Path $FilePath -PathType Leaf) {
        LOG -Message "Function RUN : $FilePath $RunParameters" -Severity INFO
        Start-Process -FilePath $FilePath -ArgumentList $RunParameters
    } else {
        LOG -Message "Function RUN : Cannot find $FilePath" -Severity ERROR
    }
}


function CREATEFOLDER {
    # Usage: CREATEFOLDER "$ProgramFilesX86\FolderName"
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$NewFolderPath
    )

    if (Test-Path -Path $NewFolderPath) {
        LOG -Message "Function CREATEFOLDER : Folder $NewFolderPath already exists" -Severity WARN
    } else {
        # TO-DO catch errors
        New-Item -Path $NewFolderPath -ItemType Directory | Out-Null
        if (Test-Path -Path $NewFolderPath) {
            LOG -Message "Function CREATEFOLDER : Folder $NewFolderPath created." -Severity INFO
        } else {
            LOG -Message "Function CREATEFOLDER : ERROR Folder $NewFolderPath not created!" -Severity ERROR
        }
    }
}

function DELFOLDER {
    # Usage: DELFOLDER "$ProgramFilesX86\FolderName"
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPathForDelete
    )

    if (Test-Path -Path $FolderPathForDelete) {
        Remove-Item $FolderPathForDelete -Recurse
        LOG -Message "Function DELFOLDER : Folder $FolderPathForDelete deleted." -Severity INFO
    } else {
        LOG -Message "Function DELFOLDER : Folder $FolderPathForDelete not found!" -Severity ERROR
    }    
}

function COPYFILE {
    # Usage: COPYFILE "$ScriptPath\README.pdf" $UserDesktop
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$CopyFilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationFolderPath
    )

    if (Test-Path -Path $CopyFilePath) {
        if (Test-Path -Path $DestinationFolderPath) {
            Copy-Item $CopyFilePath -Destination $DestinationFolderPath
            LOG -Message "Function COPYFILE : File $CopyFilePath was copied to $DestinationFolderPath" -Severity INFO
        } else {
            LOG -Message "Function COPYFILE : Folder $DestinationFolderPath not found!" -Severity ERROR
        }
    } else {
        LOG -Message "Function COPYFILE : File $CopyFilePath not found!" -Severity ERROR
    }
}

function DELFILE {
    # Usage: DELFOLDER "$ScriptPath\README.pdf"
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FilePathToDelete
    )
    
    if (Test-Path -Path $FilePathToDelete) {
        Remove-Item -Path $FilePathToDelete -Force
        LOG -Message "Function DELFILE : File $FilePathToDelete was deleted." -Severity INFO
    } else {
        # TO-DO catch errors
        LOG -Message "Function DELFILE : File $FilePathToDelete was not found!" -Severity ERROR
    }
}

#==============================================
# YOUR COMMANDS
#==============================================

# Tests
#MESSAGE "Run notepad.exe"
#RUN "$WinDir\notepad.exe"
#CREATEFOLDER "$ProgramFilesX86\TestFolder"
#MESSAGE "Folder $ProgramFilesX86\TestFolder created!"
#DELFOLDER "$ProgramFilesX86\TestFolder"
#MESSAGE $ScriptParentFolderName
#MESSAGE $ScriptFullPath
#MESSAGE $ScriptPath
#MESSAGE $UserDesktop
#COPYFILE "$ScriptPath\README.md" $UserDesktop
DELFILE "$UserDesktop\README.md"


