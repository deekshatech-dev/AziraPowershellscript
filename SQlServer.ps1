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
        #        Install-Module SqlServer -AllowClobber
        
        # Import-Module SQLPS
        Import-Module SqlServer

        $server_name = $env:COMPUTERNAME

        $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
        $output += "`nWindows Server:" + $server_name
        $output += "`nWindows Version:" + $WindowsVersion
        $SqlProductDetails = Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost"
        $output += "`n SqlProductDetails: $SqlProductDetails"

        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        $serverVersion = $server.Information.VersionString
        $output += "`n serverVersion: $serverVersion"
        $productLevel = $server.Information.ProductLevel
        $output += "`n productLevel: $productLevel"
        $FullTextSearchEnabled = $server.Information.IsFullTextInstalled
        $output += "`n FullTextSearchEnabled: $FullTextSearchEnabled"
        $TotalPhysicalMemory = $server.Information.PhysicalMemory
        $output += "`n TotalPhysicalMemory: $TotalPhysicalMemory"
        $SqlLanguage = $server.Information.Language
        $output += "`n SqlLanguage: $SqlLanguage"
        $SqlEdition = $server.Information.Edition
        $output += "`n SqlEdition: $SqlEdition"
        $dbCollationName = $server.Information.Collation
        $output += "`n dbCollationName: $dbCollationName"
        $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop

        $dbName = "PowershellDB"
        $output += "`n dbName: $dbName"
        $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"

        $isDatabaseMailEnabled = $server.Configuration.DatabaseMailEnabled.ConfigValue
        $output += "`n isDatabaseMailEnabled: isDatabaseMailEnabled"
        $databaseMailStatus = $server.Configuration.DatabaseMailEnabled.RunValue
        $output += "`n databaseMailStatus: $databaseMailStatus"
        $FileStreamConfigLevel = $server.Configuration.FilestreamAccessLevel.ConfigValue
        $output += "`n FileStreamConfigLevel: $FileStreamConfigLevel"
        $FileStreamAccessLevel = $server.Configuration.FilestreamAccessLevel.RunValue
        $output += "`n FileStreamAccessLevel: $FileStreamAccessLevel"


        $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  
        $output += "`n isClrEnabled: $isClrEnabled"
        foreach ($db in $server.Databases) {
            if ($db.Name -eq $dbName) {
                $dbRecoveryModel = $db.RecoveryModel
                $output += "`n dbRecoveryModel: $dbRecoveryModel"
                $dbCompatibilityLevel = $db.CompatibilityLevel
                $output += "`n dbCompatibilityLevel: $dbCompatibilityLevel"
                $dbLastBackupDate = $db.LastBackupDate
                $output += "`n dbLastBackupDate: $dbLastBackupDate"
            }
        }

        $folder = $server.Information.MasterDBLogPath
        # $folder
        $authenticationMode = $server.Settings.LoginMode
        $output += $authenticationMode
        foreach ($file in Get-ChildItem $folder) {
            if ($file.Name -eq "templog.ldf") {
                $tempDbLdfPath = $folder + "\" + $file.Name
                $output += "`n tempDbLdfPath:$tempDbLdfPath"
            }
            if ($file.Name -eq "templog.mdf") {
                $tempDbmdfPath = $folder + "\" + $file.Name
                $output += "`n tempDbmdfPath: $tempDbmdfPath"
            }
            else {
                if ($file.Name -match ".mdf") {
                    $mdfpath = $folder + "\" + $file.Name
                    $output += "`n MDFPath: $mdfpath"
                    $mdfsize = ( $file.Length / 1000000 ).ToString() + " MB"
                    $output += "`n MDFSize: $mdfsize"
                }
                elseif ($file.Name -match ".ldf") {
                    $ldfpath = $folder + "\" + $file.Name
                    $output += "`n LDFPath: $ldfpath"
                    $ldfsize = ( $file.Length / 1000000 ).ToString() + " MB"
                    $output += "`n LDFSize: $ldfsize"
                }
                else{

                }
                
            }


            # if ($file.Name -eq $dbName + ".mdf") {
            #     $DbMdfFilePath = $folder + "\" + $file.Name
            #     $output += "`n DbMdfFilePath: $DbMdfFilePath"
            #     $DbMdfFileSize = ( $file.Length / 1000000 ).ToString() + " MB"
            #     $output += "`n DbMdfFilePath: $DbMdfFileSize"
            # }
            # if ($file.Name -eq $dbName + "_log.ldf") {
            #     $DbLdfFilePath = $folder + "\" + $file.Name
            #     $output += "`n DbLdfFilePath: $DbLdfFilePath"
            #     $DbLdfFileSize = ( $file.Length / 1000000 ).ToString() + " MB"
            #     $output += "`n DbLdfFileSize: $DbLdfFileSize"
            # }
        }
        # $creds = Get-SqlLogin -ServerInstance "localhost"
        # foreach ($cred in $creds) {
        #     if ($cred.LoginType -ne "Certificate") {
        #         $cred
        #     }
        # }

        $backupPath = ($server.Settings.BackupDirectory).ToString() + $dbName + ".bak"
        $output += "`n backupPath: $backupPath"

    }
    End {
        return $output | Format-List
    }
}

Get-MachineDetails