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
        [string]$database = $args[0],
        [Parameter(Mandatory = $false)]
        $showWindowsVersion,
        [Parameter(Mandatory = $false)]
        $showSqlProductDetails,
        [Parameter(Mandatory = $false)]
        $showCDriveSpace,
        [Parameter(Mandatory = $false)]
        $showSqlMemoryDetails,
        [Parameter(Mandatory = $false)]
        $showDriveSpaceDetails,
        [Parameter(Mandatory = $false)]
        $showBackupPath,
        [Parameter(Mandatory = $false)]
        $showLDFSize,
        [Parameter(Mandatory = $false)]
        $showServerVersion,
        [Parameter(Mandatory = $false)]
        $showProductLevel,
        [Parameter(Mandatory = $false)]
        $showFullTextSearchEnabled,
        [Parameter(Mandatory = $false)]
        $showSqlLanguage,
        [Parameter(Mandatory = $false)]
        $showSqlEdition,
        [Parameter(Mandatory = $false)]
        $showdbCollationName,
        [Parameter(Mandatory = $false)]
        $showCLRVersion,
        [Parameter(Mandatory = $false)]
        $showSqlPort,
        [Parameter(Mandatory = $false)]
        $showServerName,
        [Parameter(Mandatory = $false)]
        $showRecomendedCpu,
        [Parameter(Mandatory = $false)]
        $showNumberFormat,
        [Parameter(Mandatory = $false)]
        $showSqlLicense,
        [Parameter(Mandatory = $false)]
        $showMaxDop,
        [Parameter(Mandatory = $false)]
        $showNumaNodes,
        [Parameter(Mandatory = $false)]
        $showCostOfThreshold,
        [Parameter(Mandatory = $false)]
        $showServerType,
        [Parameter(Mandatory = $false)]
        $showDbName,
        [Parameter(Mandatory = $false)]
        $showDbMailEnabled,
        [Parameter(Mandatory = $false)]
        $showDbMailStatus,
        [Parameter(Mandatory = $false)]
        $showFileStramConfigLevel,
        [Parameter(Mandatory = $false)]
        $showFilestreamAccessLevel,
        [Parameter(Mandatory = $false)]
        $showFilestreamSize,
        [Parameter(Mandatory = $false)]
        $showClrEnabled,
        [Parameter(Mandatory = $false)]
        $showDbRecoveryModel,
        [Parameter(Mandatory = $false)]
        $showDbCompatibilityLevel,
        [Parameter(Mandatory = $false)]
        $showDbLastBackupDate,
        [Parameter(Mandatory = $false)]
        $showTempLDFPath,
        [Parameter(Mandatory = $false)]
        $showTempMDFPath,
        [Parameter(Mandatory = $false)]
        $showMDFPath,
        [Parameter(Mandatory = $false)]
        $showMDFSize
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
            if ($showWindowsVersion) {
                $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
                $output += "`n Windows Version:" + $WindowsVersion
            }
            if (showSqlProductDetails) {
                $SqlProductDetails = Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost"
                $output += "`n SqlProductDetails: $SqlProductDetails"
            }

            if ($showCDriveSpace) {
                $used = (Get-PSDrive C | Select-Object Used).Used / 1MB
                $free = (Get-PSDrive C | Select-Object Free).Free / 1MB
                $output += "`n Hard Drive C Drive: [" + $used + "/" + $free + "]"
            }
            
            if ($showSqlMemoryDetails) {
                $UsedMemorybySql = Invoke-SqlCmd -Query "SELECT physical_memory_in_use_kb/1024 AS sqlusedmemory FROM sys.dm_os_process_memory;"  
                $output += "`n Total Memory In Use: " + $UsedMemorybySql.sqlusedmemory + "MB"
                $availableMemorybySql = Invoke-SqlCmd -Query "SELECT available_commit_limit_kb/1024 AS sqlavailmemory FROM sys.dm_os_process_memory;"
                $totalMemoryforSQL = $availableMemorybySql.sqlavailmemory + $UsedMemorybySql.sqlusedmemory
                $output += "`n Total Memory Allocated: " + $totalMemoryforSQL + "MB"
            }

            if ($showDriveSpaceDetails) {
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
            }

           

            $instanceName = "localhost"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName

            if ($showServerVersion) {
                $serverVersion = $server.Information.VersionString
                $output += "`n serverVersion: $serverVersion"
            }
            if ($showProductLevel) {
                $productLevel = $server.Information.ProductLevel
                $output += "`n productLevel: $productLevel"
            }
            if ($showFullTextSearchEnabled) {
                $FullTextSearchEnabled = $server.Information.IsFullTextInstalled
                $output += "`n FullTextSearchEnabled: $FullTextSearchEnabled"
            }
            if ($showSqlLanguage) {
                $SqlLanguage = $server.Information.Language
                $output += "`n SqlLanguage: $SqlLanguage"
            }
            if ($showSqlEdition) {
                $SqlEdition = $server.Information.Edition
                $output += "`n SqlEdition: $SqlEdition"
            }
            if ($showdbCollationName) {
                $dbCollationName = $server.Information.Collation
                $output += "`n dbCollationName: $dbCollationName"
            }
            if ($showCLRVersion) {
                $CLR = "v" + $PSVersionTable.CLRVersion.Major.ToString() + "." + $PSVersionTable.CLRVersion.Minor.ToString() + "." + $PSVersionTable.CLRVersion.Build.ToString()
                $output += "`n CLR Version $CLR"
            }
            if ($showSqlPort) {
                $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop
                $processID = $sql_services.ProcessID[0]
    
                if ($processID -ne "") {
                    $SQLPort = (((netstat -ano | findstr $processID)[0].ToString().Split('') | where { $_ -ne "" })[1].Split(":"))[1]
                }
                else {
                    $SQLPort = "N/A"
                }
            
                $output += "`n PORT: $SQLPort"
            }
            $ServerName = $env:COMPUTERNAME
            if ($showServerName) {
                $output += "`n Server Name : " + $ServerName
            }
            
            $CPUCore = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
            $RAM = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
            $drives = Get-WmiObject Win32_LogicalDisk -ComputerName $ServerName | Select -Property Size
            
            foreach ($drive  in $drives) {
                $drivename = $drive. -split ":"
                if (($drivename -ne "A") -and ($drivename -ne "B")) {
                    $totalspace += [int]($drive.Size / 1GB)
                }
            }
            $RAMGB = [int]($RAM.Split(' ')[0].Trim() / 1024) 
            
            if ($showRecomendedCpu) {
                $output += "`n Recommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"
            }
            if ($showNumberFormat) {
                $numberFormat = (Invoke-Sqlcmd -Query "select format(987654321.00, 'N', 'en-us' );").Column1
                $output += "`n Number Format(en-us): $numberFormat"
            }
            if ($showSqlLicense) {
                $sysInfo = Invoke-Sqlcmd -Query "SELECT * FROM sys.dm_os_sys_info"

                $sockets = $sysInfo.socket_count
                $coresPerSocket = $sysInfo.cores_per_socket
                $logicalProcessors = (Get-CimInstance Win32_ComputerSystem) | Select  NumberOfLogicalProcessors
                $sqlLicense = "SQL Server detected" + $sockets + "sockets with" + $coresPerSocket + "cores per socket and" + $logicalProcessors + "logical processors per socket," + $logicalProcessors + "total logical processors; using 4 logical processors based on SQL Server licensing."
                $output += "`n SQL License: $sqlLicense"
            }
            if ($showMaxDop) {
                $sqlHardwareDetails = (Test-DbaMaxDop -SqlInstance $env:COMPUTERNAME | Select-Object *)[0]
                $dbMaxDOP = $sqlHardwareDetails.DatabaseMaxDop
                $output += "`n Max DOP: $dbMaxDOP"
            }
            if ($showNumaNodes) {
                $NumaNodes = $sqlHardwareDetails.NumaNodes
                $output += "`n NUMA Nodes: $NumaNodes"
            }
            if ($showCostOfThreshold) {
                $costThresholdDOP = Invoke-Sqlcmd -Query "SELECT value FROM sys.configurations WITH (NOLOCK) WHERE name IN ('cost threshold for parallelism')"
                $output += "`n Cost of Threshold DOP: $costThresholdDOP"
            }
            if ($showServerType) {
                $ServerType = Get-WmiObject -ComputerName $ServerName -class Win32_ComputerSystem | Select -Property Model
                $output += "`n Server TYPE: $ServerType"
            }
            if ($showDbName) {
                $output += "`n dbName: $database"
            }
            $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"

            if ($showDbMailEnabled) {
                $isDatabaseMailEnabled = $server.Configuration.DatabaseMailEnabled.ConfigValue
                $output += "`n isDatabaseMailEnabled: $isDatabaseMailEnabled"
            }
            if ($showDbMailStatus) {
                $databaseMailStatus = $server.Configuration.DatabaseMailEnabled.RunValue
                $output += "`n databaseMailStatus: $databaseMailStatus"
            }
            if ($showFileStramConfigLevel) {
                $FileStreamConfigLevel = $server.Configuration.FilestreamAccessLevel.ConfigValue
                $output += "`n FileStreamConfigLevel: $FileStreamConfigLevel"
            }
            if ($showFilestreamAccessLevel) {
                $FileStreamAccessLevel = $server.Configuration.FilestreamAccessLevel.RunValue
                $output += "`n FileStreamAccessLevel: $FileStreamAccessLevel"
            }
            if ($showFilestreamSize) {
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
            }
            if ($showClrEnabled) {
                $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  
                $output += "`n isClrEnabled: $isClrEnabled"
            }

            foreach ($db in $server.Databases) {
                if ($db.Name -eq $database) {
                    $dbRecoveryModel = $db.RecoveryModel
                    $dbCompatibilityLevel = $db.CompatibilityLevel
                    $dbLastBackupDate = $db.LastBackupDate
                }
            }
            if ($showDbRecoveryModel) {
                $output += "`n dbRecoveryModel: $dbRecoveryModel"
            }
            if ($showDbCompatibilityLevel) {
                $output += "`n dbCompatibilityLevel: $dbCompatibilityLevel"
            }
            if ($showDbLastBackupDate) {
                $output += "`n dbLastBackupDate: $dbLastBackupDate"
            }

            $folder = $server.Information.MasterDBLogPath
            $authenticationMode = $server.Settings.LoginMode
            $output += $authenticationMode
            foreach ($file in Get-ChildItem $folder) {
                if ($file.Name -eq "templog.ldf") {
                    $tempDbLdfPath = $folder + "\" + $file.Name
                    if ($showTempLDFPath) {
                        $output += "`n tempDbLdfPath:$tempDbLdfPath"
                    }
                }
                if ($file.Name -eq "templog.mdf") {
                    $tempDbmdfPath = $folder + "\" + $file.Name
                    if ($showTempMDFPath) {
                        $output += "`n tempDbmdfPath: $tempDbmdfPath"
                    }
                }
                else {
                    if ($file.Name -match ".mdf") {
                        $mdfpath = $folder + "\" + $file.Name
                        if ($showMDFPath) {
                            $output += "`n MDFPath: $mdfpath"
                        }
                        $mdfsize = ( $file.Length / 1000000 ).ToString() + " MB"
                        if ($showMDFSize) {
                            $output += "`n MDFSize: $mdfsize"
                        }
                    }
                    elseif ($file.Name -match ".ldf") {
                        $ldfpath = $folder + "\" + $file.Name
                        if ($showLDFPath) {
                            $output += "`n LDFPath: $ldfpath"
                        }
                        $ldfsize = ( $file.Length / 1000000 ).ToString() + " MB"
                        if ($showLDFSize) {
                            $output += "`n LDFSize: $ldfsize"
                        }
                    }
                }
            }
            if ($showBackupPath) {
                $backupPath = ($server.Settings.BackupDirectory).ToString() + $database + ".bak"
                $output += "`n backupPath: $backupPath"    
            }
            if ($show) {
                
            }
            if ($show) {
                
            }
            

            
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