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
        $showWindowsVersion = $args[1],
        [Parameter(Mandatory = $false)]
        $showSqlProductDetails = $args[2],
        [Parameter(Mandatory = $false)]
        $showCDriveSpace = $args[3],
        [Parameter(Mandatory = $false)]
        $showSqlMemoryDetails = $args[4],
        [Parameter(Mandatory = $false)]
        $showDriveSpaceDetails = $args[5],
        [Parameter(Mandatory = $false)]
        $showBackupPath = $args[6],
        [Parameter(Mandatory = $false)]
        $showLDFSize = $args[7],
        [Parameter(Mandatory = $false)]
        $showServerVersion = $args[8],
        [Parameter(Mandatory = $false)]
        $showProductLevel = $args[9],
        [Parameter(Mandatory = $false)]
        $showFullTextSearchEnabled = $args[10],
        [Parameter(Mandatory = $false)]
        $showSqlLanguage = $args[11],
        [Parameter(Mandatory = $false)]
        $showSqlEdition = $args[12],
        [Parameter(Mandatory = $false)]
        $showdbCollationName = $args[13],
        [Parameter(Mandatory = $false)]
        $showCLRVersion = $args[14],
        [Parameter(Mandatory = $false)]
        $showSqlPort = $args[15],
        [Parameter(Mandatory = $false)]
        $showServerName = $args[16],
        [Parameter(Mandatory = $false)]
        $showRecomendedCpu = $args[17],
        [Parameter(Mandatory = $false)]
        $showNumberFormat = $args[18],
        [Parameter(Mandatory = $false)]
        $showSqlLicense = $args[19],
        [Parameter(Mandatory = $false)]
        $showMaxDop = $args[20],
        [Parameter(Mandatory = $false)]
        $showNumaNodes = $args[21],
        [Parameter(Mandatory = $false)]
        $showCostOfThreshold = $args[22],
        [Parameter(Mandatory = $false)]
        $showServerType = $args[23],
        [Parameter(Mandatory = $false)]
        $showDbName = $args[24],
        [Parameter(Mandatory = $false)]
        $showDbMailEnabled = $args[25],
        [Parameter(Mandatory = $false)]
        $showDbMailStatus = $args[26],
        [Parameter(Mandatory = $false)]
        $showFileStramConfigLevel = $args[27],
        [Parameter(Mandatory = $false)]
        $showFilestreamAccessLevel = $args[28],
        [Parameter(Mandatory = $false)]
        $showFilestreamSize = $args[29],
        [Parameter(Mandatory = $false)]
        $showClrEnabled = $args[30],
        [Parameter(Mandatory = $false)]
        $showDbRecoveryModel = $args[31],
        [Parameter(Mandatory = $false)]
        $showDbCompatibilityLevel = $args[32],
        [Parameter(Mandatory = $false)]
        $showDbLastBackupDate = $args[33],
        [Parameter(Mandatory = $false)]
        $showTempLDFPath = $args[34],
        [Parameter(Mandatory = $false)]
        $showTempMDFPath = $args[35],
        [Parameter(Mandatory = $false)]
        $showMDFPath = $args[36],
        [Parameter(Mandatory = $false)]
        $showMDFSize = $args[37]
    )

    Begin {
        $output = ""
        $totalspace = 0
        $outputFolder = "./Output/SqlServer"
        $outputFile = "./SqlServer_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".csv"
        If (!(Test-Path $outputFolder)) {
            New-Item -Path $outputFolder -ItemType Directory
        }
        If (!(Test-Path "./error_log")) {
            New-Item -Path "./error_log" -ItemType Directory
        }
        try {
            Import-Module SqlServer 
            #           Import-Module SQLPS 
            Import-Module dbatools 
        }
        catch {
            "Installing Prerequistic....Please wait"
            Install-Module dbatools -AllowClobber
            Install-Module SqlServer -AllowClobber
            Import-Module SqlServer 
            #            Import-Module SQLPS 
            Import-Module dbatools 

        }
        if (!$showWindowsVersion) {
            if (($showWindowsVersion -eq 0)) {
                $showWindowsVersion = $false
            }
            else {
                $showWindowsVersion = $true
            }
        }
        if (!$showSqlProductDetails) {
            if (($showSqlProductDetails -eq 0)) {
                $showSqlProductDetails = $false
            }
            else {
                $showSqlProductDetails = $true
            }
        }
        if (!$showCDriveSpace) {
            if (($showCDriveSpace -eq 0)) {
                $showCDriveSpace = $false
            }
            else {
                $showCDriveSpace = $true
            }
        }
        if (!$showSqlMemoryDetails) {
            if (($showSqlMemoryDetails -eq 0)) {
                $showSqlMemoryDetails = $false
            }
            else {
                $showSqlMemoryDetails = $true
            }
        }
        if (!$showDriveSpaceDetails) {
            if (($showDriveSpaceDetails -eq 0)) {
                $showDriveSpaceDetails = $false
            }
            else {
                $showDriveSpaceDetails = $true
            }
        }
        if (!$showBackupPath) {
            if (($showBackupPath -eq 0)) {
                $showBackupPath = $false
            }
            else {
                $showBackupPath = $true
            }
        }
        if (!$showLDFSize) {
            if (($showLDFSize -eq 0)) {
                $showLDFSize = $false
            }
            else {
                $showLDFSize = $true
            }
        }
        if (!$showServerVersion) {
            if (($showServerVersion -eq 0)) {
                $showServerVersion = $false
            }
            else {
                $showServerVersion = $true
            }
        }
        if (!$showProductLevel) {
            if (($showProductLevel -eq 0)) {
                $showProductLevel = $false
            }
            else {
                $showProductLevel = $true
            }
        }
        if (!$showFullTextSearchEnabled) {
            if (($showFullTextSearchEnabled -eq 0)) {
                $showFullTextSearchEnabled = $false
            }
            else {
                $showFullTextSearchEnabled = $true
            }
        }
        if (!$showSqlLanguage) {
            if (($showSqlLanguage -eq 0)) {
                $showSqlLanguage = $false
            }
            else {
                $showSqlLanguage = $true
            }
        }
        if (!$showSqlEdition) {
            if (($showSqlEdition -eq 0)) {
                $showSqlEdition = $false
            }
            else {
                $showSqlEdition = $true
            }
        }
        if (!$showdbCollationName) {
            if (($showdbCollationName -eq 0)) {
                $showdbCollationName = $false
            }
            else {
                $showdbCollationName = $true
            }
        }
        if (!$showCLRVersion) {
            if (($showCLRVersion -eq 0)) {
                $showCLRVersion = $false
            }
            else {
                $showCLRVersion = $true
            }
        }
        if (!$showSqlPort) {
            if (($showSqlPort -eq 0)) {
                $showSqlPort = $false
            }
            else {
                $showSqlPort = $true
            }
        }
        if (!$showServerName) {
            if (($showServerName -eq 0)) {
                $showServerName = $false
            }
            else {
                $showServerName = $true
            }
        }
        if (!$showRecomendedCpu) {
            if (($showRecomendedCpu -eq 0)) {
                $showRecomendedCpu = $false
            }
            else {
                $showRecomendedCpu = $true
            }
        }
        if (!$showNumberFormat) {
            if (($showNumberFormat -eq 0)) {
                $showNumberFormat = $false
            }
            else {
                $showNumberFormat = $true
            }
        }
        if (!$showSqlLicense) {
            if (($showSqlLicense -eq 0)) {
                $showSqlLicense = $false
            }
            else {
                $showSqlLicense = $true
            }
        }
        if (!$showMaxDop) {
            if (($showMaxDop -eq 0)) {
                $showMaxDop = $false
            }
            else {
                $showMaxDop = $true
            }
        }
        if (!$showNumaNodes) {
            if (($showNumaNodes -eq 0)) {
                $showNumaNodes = $false
            }
            else {
                $showNumaNodes = $true
            }
        }
        if (!$showCostOfThreshold) {
            if (($showCostOfThreshold -eq 0)) {
                $showCostOfThreshold = $false
            }
            else {
                $showCostOfThreshold = $true
            }
        }
        if (!$showServerType) {
            if (($showServerType -eq 0)) {
                $showServerType = $false
            }
            else {
                $showServerType = $true
            }
        }
        if (!$showDbName) {
            if (($showDbName -eq 0)) {
                $showDbName = $false
            }
            else {
                $showDbName = $true
            }
        }
        if (!$showDbMailEnabled) {
            if (($showDbMailEnabled -eq 0)) {
                $showDbMailEnabled = $false
            }
            else {
                $showDbMailEnabled = $true
            }
        }
        if (!$showDbMailStatus) {
            if (($showDbMailStatus -eq 0)) {
                $showDbMailStatus = $false
            }
            else {
                $showDbMailStatus = $true
            }
        }
        if (!$showFileStramConfigLevel) {
            if (($showFileStramConfigLevel -eq 0)) {
                $showFileStramConfigLevel = $false
            }
            else {
                $showFileStramConfigLevel = $true
            }
        }
        if (!$showFilestreamAccessLevel) {
            if (($showFilestreamAccessLevel -eq 0)) {
                $showFilestreamAccessLevel = $false
            }
            else {
                $showFilestreamAccessLevel = $true
            }
        }
        if (!$showFilestreamSize) {
            if (($showFilestreamSize -eq 0)) {
                $showFilestreamSize = $false
            }
            else {
                $showFilestreamSize = $true
            }
        }
        if (!$showClrEnabled) {
            if (($showClrEnabled -eq 0)) {
                $showClrEnabled = $false
            }
            else {
                $showClrEnabled = $true
            }
        }

        if (!$showDbRecoveryModel) {
            if (($showDbRecoveryModel -eq 0)) {
                $showDbRecoveryModel = $false
            }
            else {
                $showDbRecoveryModel = $true
            }
        }
        if (!$showDbCompatibilityLevel) {
            if (($showDbCompatibilityLevel -eq 0)) {
                $showDbCompatibilityLevel = $false
            }
            else {
                $showDbCompatibilityLevel = $true
            }
        }
        if (!$showDbLastBackupDate) {
            if (($showDbLastBackupDate -eq 0)) {
                $showDbLastBackupDate = $false
            }
            else {
                $showDbLastBackupDate = $true
            }
        }
        if (!$showTempLDFPath) {
            if (($showTempLDFPath -eq 0)) {
                $showTempLDFPath = $false
            }
            else {
                $showTempLDFPath = $true
            }
        }
        if (!$showTempMDFPath) {
            if (($showTempMDFPath -eq 0)) {
                $showTempMDFPath = $false
            }
            else {
                $showTempMDFPath = $true
            }
        }
        if (!$showMDFPath) {
            if (($showMDFPath -eq 0)) {
                $showMDFPath = $false
            }
            else {
                $showMDFPath = $true
            }
        }
        if (!$showMDFSize) {
            if (($showMDFSize -eq 0)) {
                $showMDFSize = $false
            }
            else {
                $showMDFSize = $true
            }
        }
    }
    Process {   
        # Install-Module SqlServer -AllowClobber
        # Import-Module SQLPS
        # Import-Module SqlServer
        $erroFile = "./error_log/sqlserver_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        $server_name = $env:COMPUTERNAME
        try {
            
            $output += "`n================================================"
            $output += "`n Windows Details"
            $output += "`n================================================"
            if ($showWindowsVersion) {
                $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
                $output += "`n Windows Version:" + $WindowsVersion
            }
            if ($showSqlMemoryDetails) {
                $UsedMemorybySql = Invoke-SqlCmd -Query "SELECT physical_memory_in_use_kb/1024 AS sqlusedmemory FROM sys.dm_os_process_memory;"  
                $output += "`n Total Memory In Use: " + $UsedMemorybySql.sqlusedmemory + "MB"
                $availableMemorybySql = Invoke-SqlCmd -Query "SELECT available_commit_limit_kb/1024 AS sqlavailmemory FROM sys.dm_os_process_memory;"
                $totalMemoryforSQL = $availableMemorybySql.sqlavailmemory + $UsedMemorybySql.sqlusedmemory
                $output += "`n Total Memory Allocated: " + $totalMemoryforSQL + "MB"
            }
            if ($showCDriveSpace) {
                $used = (Get-PSDrive C | Select-Object Used).Used / 1MB
                $free = (Get-PSDrive C | Select-Object Free).Free / 1MB
                $output += "`n Hard Drive C Drive: [" + $used + "/" + $free + "]"
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
            $output += "`n================================================"
            $output += "`n Sql Server  Details"
            $output += "`n================================================"
            $ServerName = $env:COMPUTERNAME
            if ($showServerName) {
                $output += "`n Server Name : " + $ServerName
            }
            if ($showRecomendedCpu) {
                $output += "`n Recommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"
            }
            if (showSqlProductDetails) {
                $SqlProductDetails = (Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost").Column1
                $output += "`n SqlProductDetails: $SqlProductDetails"
            }

            $instanceName = "localhost"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $databases = $server.Databases
            $databaseExist = $false
            foreach ($db in $databases) {
                If ($db.Name -eq $database) {
                    $databaseExist = $true
                }
            }
            if ($databaseExist) {
                
            }
            else {
                $database + " does not Exist!"
            }

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
            
            
            if ($showNumberFormat) {
                $numberFormat = (Invoke-Sqlcmd -Query "select format(987654321.00, 'N', 'en-us' );").Column1
                $output += "`n Number Format(en-us): $numberFormat"
            }
            if ($showSqlLicense) {
                $sysInfo = Invoke-Sqlcmd -Query "SELECT * FROM sys.dm_os_sys_info"

                $sockets = $sysInfo.socket_count
                $coresPerSocket = $sysInfo.cores_per_socket
                $logicalProcessors = (Get-CimInstance Win32_ComputerSystem) | Select  NumberOfLogicalProcessors
                $sqlLicense = "SQL Server detected " + $sockets + " sockets with " + $coresPerSocket.NumberOfLogicalProcessors + " cores per socket and " + $logicalProcessors.NumberOfLogicalProcessors + " logical processors per socket, " + $logicalProcessors.NumberOfLogicalProcessors + " total logical processors; using 4 logical processors based on SQL Server licensing."
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
                $ServerType = (Get-WmiObject -ComputerName $ServerName -class Win32_ComputerSystem | Select -Property Model).Model
                $output += "`n Server TYPE: $ServerType"
            }
            if ($showDbName) {
                $output += "`n dbName: $database"
            }
            $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"
            if ($databaseExist) {
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

                    if ($showBackupPath) {
                        $backupPath = ($server.Settings.BackupDirectory).ToString() + $database + ".bak"
                        $output += "`n backupPath: $backupPath"    
                    }
               
                
                    $output += "`n FILESTREAM FILE Path: $FileStreamFilePath"
                    $output += "`n FILESTREAM FILE Size: $FileStreamFileSize"
                }

            }
            else {
                "Database Not Found!"
            }

            if ($showClrEnabled) {
                $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  
                $output += "`n isClrEnabled: $isClrEnabled"
            }

            foreach ($db in $server.Databases) {
                if ($db.Name -eq $database) {
                    if ($showDbRecoveryModel) {
                        $dbRecoveryModel = $db.RecoveryModel
                        $output += "`n dbRecoveryModel: $dbRecoveryModel"
                    }
                    if ($showDbCompatibilityLevel) {
                        $dbCompatibilityLevel = $db.CompatibilityLevel
                        $output += "`n dbCompatibilityLevel: $dbCompatibilityLevel"
                    }
                    if ($showDbLastBackupDate) {
                        $dbLastBackupDate = $db.LastBackupDate.ToString("MM/dd/yyyy")
                        if ($dbLastBackupDate -eq "01/01/0001") {
                            $output += "`n dbLastBackupDate: N/A"
                        }
                        else {
                            $output += "`n dbLastBackupDate: $dbLastBackupDate"
                        }
                    }
                }
            }

            $folder = $server.Information.MasterDBLogPath
            $authenticationMode = $server.Settings.LoginMode
            $output += $authenticationMode
            foreach ($file in Get-ChildItem $folder) {
                if ($file.Name -eq "templog.ldf") {
                    if ($showTempLDFPath) {
                        $tempDbLdfPath = $folder + "\" + $file.Name
                        $output += "`n tempDbLdfPath:$tempDbLdfPath"
                    }
                }
                if ($file.Name -eq "templog.mdf") {
                    if ($showTempMDFPath) {
                        $tempDbmdfPath = $folder + "\" + $file.Name
                        $output += "`n tempDbmdfPath: $tempDbmdfPath"
                    }
                }
                else {
                    if ($file.Name -match ".mdf") {
                        if ($showMDFPath) {
                            $mdfpath = $folder + "\" + $file.Name
                            $output += "`n MDFPath: $mdfpath"
                        }
                        if ($showMDFSize) {
                            $mdfsize = ( $file.Length / 1000000 ).ToString() + " MB"
                            $output += "`n MDFSize: $mdfsize"
                        }
                    }
                    elseif ($file.Name -match ".ldf") {
                        if ($showLDFPath) {
                            $ldfpath = $folder + "\" + $file.Name
                            $output += "`n LDFPath: $ldfpath"
                        }
                        if ($showLDFSize) {
                            $ldfsize = ( $file.Length / 1000000 ).ToString() + " MB"
                            $output += "`n LDFSize: $ldfsize"
                        }
                    }
                }
            }
        }
        catch {
            $err = $_
            $ErrorStackTrace = $_.ScriptStackTrace 
            $ErrorBlock = ($err).ToString() + "`n`nStackTrace: " + ($ErrorStackTrace).ToString()
            Set-Content -Path $erroFile -Value $ErrorBlock
            "Some error occured check " + $erroFile + " for stacktrace"
        }
    }
    End {
        $filePath = $outputFolder + "/" + $outputFile
        $output | Out-File -Append $filePath -Encoding UTF8
        Write-Host "Check the output at File "  $filePath -ForegroundColor Yellow
        return $output | Format-List
    }
}
Get-MachineDetails