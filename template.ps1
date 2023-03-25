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
# NASTAVENI PROMENY, NEUPRAVOVAT
#==============================================
# Seznam vsech systemovych promennych > Get-Childitem -Path Env:* | Sort-Object Name
$LogPath = $Env:SystemDrive + "\applogs"
$ScriptName = $MyInvocation.MyCommand.Name
$ScriptParentFolder = Split-Path (Get-Location) -Leaf
$WinDir = $Env:windir
$WinDirSys32 = $Env:windir + "\system32"


#==============================================
# NAZEV BALICKU
#==============================================
$PackageName = ""

#==============================================
# KONFIGURACE LOGOVANI
#==============================================
$LogToCSV = $true
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
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
    if ($LogToCSV -eq "True") {
    [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
        Severity = $Severity
    } | Export-Csv -Path $LogFile -Append -NoTypeInformation
    } else {
        $Time = (Get-Date -f g)
        $LogMessage = "$Time : $Message"
        Add-content $LogFile -value $LogMessage
    }
}
#LOG -Message "Start" -Severity Information
LOG "Start"

function MESSAGE {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$msgBody
    )
    LOG -Message "Function MESSAGE : $msgBody" -Severity Information
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    [System.Windows.MessageBox]::Show($msgBody)
}

function RUN {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FilePath,

        [Parameter()]
        [string]$RunParameters
    )

    if (Test-Path -Path $FilePath -PathType Leaf) {
        LOG -Message "Function RUN : $FilePath $RunParameters" -Severity Information
        Start-Process -FilePath $FilePath -ArgumentList $RunParameters
    } else {
        LOG -Message "Function RUN : ERROR : Cannot find $FilePath" -Severity Error
    }
    

}

#==============================================
# Script
#==============================================

#MESSAGE "Zprava"
RUN "notepad.exe"
