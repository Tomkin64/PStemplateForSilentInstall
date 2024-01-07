# PStemplateForSilentInstall
PowerShell template for easy automate Windows application installation

Functions:
- LOG - create log file contains commands and status and has 3 severity levels 'INFO','WARN','ERROR' - useful for debugging
- MESSAGE - show simple Windows Message Box with given string
    ```Usage: MESSAGE "Folder $ProgramFilesX86\TestFolder created!"```
- RUN - Run application or setup with or without parameters
    ```Usage: RUN "$WinDir\notepad.exe"```
    or
    ```Usage: RUN "$ScriptPath\setup.exe" "/S"```
- CREATEFOLDER - create folder with folder path
    ```Usage: CREATEFOLDER "$ProgramFilesX86\FolderName"```
- DELFOLDER - delete folder with given folder path
    ```Usage: DELFOLDER "$ProgramFilesX86\FolderName"```
- COPYFILE - copy file to give filepath
    ```Usage: COPYFILE "$ScriptPath\README.pdf" $UserDesktop```
- DELFILE - delete file
    ```Usage: DELFOLDER "$ScriptPath\README.pdf"```
- REGEXISTS - check if given Registry key is exists
    ```Usage: REGEXISTS -RegKey "HKLM:\SOFTWARE\Key" -RegName "Name"```