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
    
    <#
        .PARAMETER database
            Sets name of the Database you want details of.
    #>
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        #$RemoteComputerName
        [string]$database = $args[0]
    )

    Begin {
        $output = ""
        $totalspace = 0
        
    }
    Process {   
        # Install-Module SqlServer -AllowClobber
        # Import-Module SQLPS
        # Import-Module SqlServer
        $erroFile = "./error_log/sqlserver_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        $server_name = $env:COMPUTERNAME
        try {
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            $output += "`n Windows Version:" + $WindowsVersion
            $SqlProductDetails = Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost"
            $output += "`n SqlProductDetails: $SqlProductDetails"

            $used = (Get-PSDrive C | Select-Object Used).Used / 1MB
            $free = (Get-PSDrive C | Select-Object Free).Free / 1MB
            $output += "`n Hard Drive C Drive: [" + $used + "/" + $free + "]"
        
            $UsedMemorybySql = Invoke-SqlCmd -Query "SELECT physical_memory_in_use_kb/1024 AS sqlusedmemory FROM sys.dm_os_process_memory;"  
            $output += "`n Total Memory In Use: " + $UsedMemorybySql.sqlusedmemory + "MB"
            $availableMemorybySql = Invoke-SqlCmd -Query "SELECT available_commit_limit_kb/1024 AS sqlavailmemory FROM sys.dm_os_process_memory;"
            $totalMemoryforSQL = $availableMemorybySql.sqlavailmemory + $UsedMemorybySql.sqlusedmemory
            $output += "`n Total Memory Allocated: " + $totalMemoryforSQL + "MB"

            $allDriveSpace = Get-WmiObject -Class win32_logicaldisk -ComputerName $server_name
    
            $totalAvailableSpace = 0;
            $totalSpace = 0;
    
            foreach ($drive in $allDriveSpace) {
                $totalAvailableSpace += $drive.FreeSpace
                $totalSpace += $drive.Size
            }
            $totalAvailableSpace = $totalAvailableSpace / 1MB 
            $totalSpace = $totalSpace / 1MB
            $output += "`n Available Physical Memory: $totalAvailableSpace"
            $output += "`n Total Physical Memory: $totalSpace"

            $instanceName = "localhost"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $serverVersion = $server.Information.VersionString
            $output += "`n serverVersion: $serverVersion"
            $productLevel = $server.Information.ProductLevel
            $output += "`n productLevel: $productLevel"
            $FullTextSearchEnabled = $server.Information.IsFullTextInstalled
            $output += "`n FullTextSearchEnabled: $FullTextSearchEnabled"
            $SqlLanguage = $server.Information.Language
            $output += "`n SqlLanguage: $SqlLanguage"
            $SqlEdition = $server.Information.Edition
            $output += "`n SqlEdition: $SqlEdition"
            $dbCollationName = $server.Information.Collation
            $output += "`n dbCollationName: $dbCollationName"
            $CLR = "v" + $PSVersionTable.CLRVersion.Major.ToString() + "." + $PSVersionTable.CLRVersion.Minor.ToString() + "." + $PSVersionTable.CLRVersion.Build.ToString()
            $output += "`n CLR Version $CLR"

            $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop
            $processID = $sql_services.ProcessID[0]

            if ($processID -ne "") {
                $SQLPort = (((netstat -ano | findstr $processID)[0].ToString().Split('') | where { $_ -ne "" })[1].Split(":"))[1]
            }
            else {
                $SQLPort = "N/A"
            }
        
            $output += "`n PORT: $SQLPort"
            $CPUCore = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
            $RAM = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
        
            $ServerName = $env:COMPUTERNAME
            $drives = Get-WmiObject Win32_LogicalDisk -ComputerName $ServerName | Select -Property Size
            $output += "`n Server Name : " + $ServerName
            foreach ($drive  in $drives) {
                $drivename = $drive. -split ":"
                if (($drivename -ne "A") -and ($drivename -ne "B")) {
                    $totalspace += [int]($drive.Size / 1GB)
                }
            }
            $RAMGB = [int]($RAM.Split(' ')[0].Trim() / 1024) 
            $output += "`n Recommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"

            $sysInfo = Invoke-Sqlcmd -Query "SELECT * FROM sys.dm_os_sys_info"

            $sockets = $sysInfo.socket_count
            $coresPerSocket = $sysInfo.cores_per_socket
            $logicalProcessors = (Get-CimInstance Win32_ComputerSystem) | Select  NumberOfLogicalProcessors
            $sqlLicense = "SQL Server detected" + $sockets + "sockets with" + $coresPerSocket + "cores per socket and" + $logicalProcessors + "logical processors per socket," + $logicalProcessors + "total logical processors; using 4 logical processors based on SQL Server licensing."
            $output += "`n SQL License: $sqlLicense"

            $sqlHardwareDetails = (Test-DbaMaxDop -SqlInstance $env:COMPUTERNAME | Select-Object *)[0]
            $dbMaxDOP = $sqlHardwareDetails.DatabaseMaxDop
            $output += "`n Max DOP: $dbMaxDOP"
            $NumaNodes = $sqlHardwareDetails.NumaNodes
            $output += "`n NUMA Nodes: $NumaNodes"
            $costThresholdDOP = Invoke-Sqlcmd -Query "SELECT value FROM sys.configurations WITH (NOLOCK) WHERE name IN ('cost threshold for parallelism')"
            $output += "`n Cost of Threshold DOP: $costThresholdDOP"
        
            $ServerType = Get-WmiObject -ComputerName $ServerName -class Win32_ComputerSystem | Select -Property Model
            $output += "`n Server TYPE: $ServerType"

            $output += "`n dbName: $database"
            $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"
            $isDatabaseMailEnabled = $server.Configuration.DatabaseMailEnabled.ConfigValue
            $output += "`n isDatabaseMailEnabled: $isDatabaseMailEnabled"
            $databaseMailStatus = $server.Configuration.DatabaseMailEnabled.RunValue
            $output += "`n databaseMailStatus: $databaseMailStatus"
            $FileStreamConfigLevel = $server.Configuration.FilestreamAccessLevel.ConfigValue
            $output += "`n FileStreamConfigLevel: $FileStreamConfigLevel"
            $FileStreamAccessLevel = $server.Configuration.FilestreamAccessLevel.RunValue
            $output += "`n FileStreamAccessLevel: $FileStreamAccessLevel"
            $FileStreamFileSize = 0;
            $FileStreamFilePath = "Filestream Not enabled in DB.";

            if ($FileStreamConfigLevel -ne 0) {
                $dbfiles = Invoke-Sqlcmd -Query "Use $database Select * from sys.database_files;"

                foreach ($file in $dbfiles) {
                    if ($file.type_desc -eq "FILESTREAM") {
                        $FileStreamFileSize = $file.size
                        $FileStreamFilePath = $file.physical_name
                    }
                }
            }
            $output += "`n FILESTREAM FILE Path: $FileStreamFilePath"
            $output += "`n FILESTREAM FILE Size: $FileStreamFileSize"


            $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  
            $output += "`n isClrEnabled: $isClrEnabled"
            foreach ($db in $server.Databases) {
                if ($db.Name -eq $database) {
                    $dbRecoveryModel = $db.RecoveryModel
                    $output += "`n dbRecoveryModel: $dbRecoveryModel"
                    $dbCompatibilityLevel = $db.CompatibilityLevel
                    $output += "`n dbCompatibilityLevel: $dbCompatibilityLevel"
                    $dbLastBackupDate = $db.LastBackupDate
                    $output += "`n dbLastBackupDate: $dbLastBackupDate"
                }
            }

            $folder = $server.Information.MasterDBLogPath
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
                    else {

                    }
                
                }
            }

            $backupPath = ($server.Settings.BackupDirectory).ToString() + $database + ".bak"
            $output += "`n backupPath: $backupPath"
        }
        catch {
            $err = $_ + $_.ScriptStackTrace 
            Set-Content -Path $erroFile -Value $err 
        }
        

    }
    End {
        return $output | Format-List
    }
}
Get-MachineDetails