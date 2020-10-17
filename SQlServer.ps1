<#
.Synopsis
   Powershell tool for GUI way for getting CPU, Memory and Disk of a machine
.DESCRIPTION
   The tool will ask for file(containing servers name) and folder(where the output will be saved as ServerrInventory.csv.
.EXAMPLE
   It is tool, and has forms and buttons to help you.
.NOTES    
    Author: Prashant kankhara
    Email : prashantkankhara@gmail.com
    Version: 0.1 
    DateCreated: 14th Oct 2020
#>

function Get-MachineDetails {
    
    Param
    (
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
    )

    Begin {
        $output = ""
        $totalspace = 0
        
    }
    Process {   
        # Import-Module SQLPS
        Import-Module SqlServer

        $server_name = $env:COMPUTERNAME

        $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
        $output += "`nWindows Version:" + $WindowsVersion
        $SqlProductDetails = Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost"

        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        $serverVersion = $server.Information.VersionString

        $productLevel = $server.Information.ProductLevel

        $FullTextSearchEnabled = $server.Information.IsFullTextInstalled

        $TotalPhysicalMemory = $server.Information.PhysicalMemory
         
        $SqlLanguage = $server.Information.Language

        $SqlEdition = $server.Information.Edition

        $dbCollationName = $server.Information.Collation

        $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop

        $dbName = "PowershellDB"
        $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"

        $isDatabaseMailEnabled = $server.Configuration.DatabaseMailEnabled.ConfigValue
        $databaseMailStatus = $server.Configuration.DatabaseMailEnabled.RunValue
        $FileStreamConfigLevel = $server.Configuration.FilestreamAccessLevel.ConfigValue
        $FileStreamAccessLevel = $server.Configuration.FilestreamAccessLevel.RunValue


        $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  

        foreach ($db in $server.Databases) {
            if ($db.Name -eq $dbName) {
                $dbRecoveryModel = $db.RecoveryModel
                $dbCompatibilityLevel = $db.CompatibilityLevel
                $dbLastBackupDate = $db.LastBackupDate
            }
        }

        $folder = $server.Information.MasterDBLogPath
        
        $authenticationMode = $server.Settings.LoginMode

        foreach ($file in Get-ChildItem $folder) {
            if ($file.Name -eq "templog.ldf") {
                $tempDbLdfPath = $folder + "\" + $file.Name
            }
            if ($file.Name -eq "templog.mdf") {
                $tempDbmdfPath = $folder + "\" + $file.Name
            }
            if ($file.Name -eq $dbName + ".mdf") {
                $DbMdfFilePath = $folder + "\" + $file.Name
                $DbMdfFileSize = ( $file.Length / 1000000 ).ToString() + " MB"
            }
            if ($file.Name -eq $dbName + "_log.ldf") {
                $DbLdfFilePath = $folder + "\" + $file.Name
                $DbLdfFileSize = ( $file.Length / 1000000 ).ToString() + " MB"
            }
        }
        $creds = Get-SqlLogin -ServerInstance "localhost"
        foreach ($cred in $creds) {
            if ($cred.LoginType -ne "Certificate") {
                $cred
            }
        }

        $backupPath = ($server.Settings.BackupDirectory).ToString() + $dbName + ".bak"

    }
    End {
        return $output | Format-List
    }
}

Get-MachineDetails