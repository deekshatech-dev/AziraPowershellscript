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
        $output += "SqlProductDetails: $SqlProductDetails"

        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        $serverVersion = $server.Information.VersionString
        $output += "serverVersion: $serverVersion"
        $productLevel = $server.Information.ProductLevel
        $output += "productLevel: $productLevel"
        $FullTextSearchEnabled = $server.Information.IsFullTextInstalled
        $output += "FullTextSearchEnabled: $FullTextSearchEnabled"
        $TotalPhysicalMemory = $server.Information.PhysicalMemory
        $output += "TotalPhysicalMemory: $TotalPhysicalMemory"
        $SqlLanguage = $server.Information.Language
        $output += "SqlLanguage: $SqlLanguage"
        $SqlEdition = $server.Information.Edition
        $output += "SqlEdition: $SqlEdition"
        $dbCollationName = $server.Information.Collation
        $output += "dbCollationName: $dbCollationName"
        $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop

        $dbName = "PowershellDB"
        $output += "dbName: $dbName"
        $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"

        $isDatabaseMailEnabled = $server.Configuration.DatabaseMailEnabled.ConfigValue
        $output += "isDatabaseMailEnabled: isDatabaseMailEnabled"
        $databaseMailStatus = $server.Configuration.DatabaseMailEnabled.RunValue
        $output += "databaseMailStatus: $databaseMailStatus"
        $FileStreamConfigLevel = $server.Configuration.FilestreamAccessLevel.ConfigValue
        $output += "FileStreamConfigLevel: $FileStreamConfigLevel"
        $FileStreamAccessLevel = $server.Configuration.FilestreamAccessLevel.RunValue
        $output += "FileStreamAccessLevel: $FileStreamAccessLevel"


        $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  
        $output += "isClrEnabled: $isClrEnabled"
        foreach ($db in $server.Databases) {
            if ($db.Name -eq $dbName) {
                $dbRecoveryModel = $db.RecoveryModel
                $output += "dbRecoveryModel: $dbRecoveryModel"
                $dbCompatibilityLevel = $db.CompatibilityLevel
                $output += "dbCompatibilityLevel: $dbCompatibilityLevel"
                $dbLastBackupDate = $db.LastBackupDate
                $output += "dbLastBackupDate: $dbLastBackupDate"
            }
        }

        $folder = $server.Information.MasterDBLogPath
        $folder
        $authenticationMode = $server.Settings.LoginMode
        $output += $authenticationMode
        foreach ($file in Get-ChildItem $folder) {
            if ($file.Name -eq "templog.ldf") {
                $tempDbLdfPath = $folder + "\" + $file.Name
                $output += "tempDbLdfPath:$tempDbLdfPath"
            }
            if ($file.Name -eq "templog.mdf") {
                $tempDbmdfPath = $folder + "\" + $file.Name
                $output += "tempDbmdfPath: $tempDbmdfPath"
            }
            if ($file.Name -eq $dbName + ".mdf") {
                $DbMdfFilePath = $folder + "\" + $file.Name
                $output += "DbMdfFilePath: $DbMdfFilePath"
                $DbMdfFileSize = ( $file.Length / 1000000 ).ToString() + " MB"
                $output += "DbMdfFilePath: $DbMdfFileSize"
            }
            if ($file.Name -eq $dbName + "_log.ldf") {
                $DbLdfFilePath = $folder + "\" + $file.Name
                $output += "DbLdfFilePath: $DbLdfFilePath"
                $DbLdfFileSize = ( $file.Length / 1000000 ).ToString() + " MB"
                $output += "DbLdfFileSize: $DbLdfFileSize"
            }
        }
        $creds = Get-SqlLogin -ServerInstance "localhost"
        foreach ($cred in $creds) {
            if ($cred.LoginType -ne "Certificate") {
                $cred
            }
        }

        $backupPath = ($server.Settings.BackupDirectory).ToString() + $dbName + ".bak"
        $output += "backupPath: $backupPath"

    }
    End {
        return $output | Format-List
    }
}

Get-MachineDetails