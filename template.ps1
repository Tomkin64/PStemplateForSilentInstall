# PowerShell Template
# Author: Tomas Kadlec, info@tomkadlec.cz
# Version 0.1
# Vyplnit radek 22 promena "sPackageName"
#----------------------------------------
# AUTOR SCRIPTU :
# DATUM         :
# POPIS         :
#----------------------------------------
#==============================================
# NASTAVENI PROMENYCH, NEUPRAVOVAT
#==============================================
# Seznam vsech systemovych promennych > Get-Childitem -Path Env:* | Sort-Object Name
$ScriptName = $MyInvocation.MyCommand.Name
$ScriptFullPath = $MyInvocation.MyCommand.Path
$ScriptParentFolder = Split-Path (Get-Location) -Leaf
$WinDir = $Env:windir
$ProgramData = $Env:ProgramData     # C:\ProgramData
$ProgramFiles = $Env:ProgramFiles     # C:\Program Files
$ProgramFilesX86 = ${Env:ProgramFiles(x86)}     # C:\Program Files (x86)


# Upravit dle potreby
$LogPath = $Env:SystemDrive + "\applogs"
$DateFormat = "dd.MM.yyyy HH:mm:ss"
$Now = (Get-Date -f $DateFormat)

#==============================================
# NAZEV BALICKU A FORMAT DATA
#==============================================

$PackageName = ""

#==============================================
# KONFIGURACE LOGOVANI
#==============================================
$LogToCSV = $false
if ($LogToCSV) {
    $LogExt = ".csv"
} else {
    $LogExt = ".log"
}
if ($PackageName -eq "" -or $PackageName -eq $null) {
    $LogFile = $LogPath + "\" + $ScriptParentFolder + "_" + $ScriptName + $LogExt
} else {
    $LogFile = $LogPath + "\" + $PackageName + "_" + $ScriptName + $LogExt
}

#==============================================
# FUNKCE
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
    if ($LogToCSV) {
    [PSCustomObject]@{
        Time = $Now
        Severity = $Severity
        Message = $Message
    } | Export-Csv -Path $LogFile -Append -NoTypeInformation
    } else {
        Add-content $LogFile -Value "$Now : $Severity : $Message"
    }
}
LOG -Message "Start $ScriptFullPath" -Severity INFO


function MESSAGE {
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

#==============================================
# Script
#==============================================

# Tests
#MESSAGE "Run notepad.exe"
#RUN "$WinDir\notepad.exe"
#CREATEFOLDER "$ProgramFilesX86\TestFolder"

