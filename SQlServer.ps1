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
"Get Details about SQL Server: Connection Timeout, SQL version, Memory Allocation Details, Database files details, Port running on, Server type, Hardware usage, FIlestreamDetails, etc."
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
    }
    Process {   
        # Install-Module SqlServer -AllowClobber
        # Import-Module SQLPS
        # Import-Module SqlServer
        $erroFile = "./error_log/sqlserver_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        $server_name = $env:COMPUTERNAME
        try {
            $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
            $SqlProductDetails = (Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost").Column1

            $used = (Get-PSDrive C | Select-Object Used).Used / 1MB
            $free = (Get-PSDrive C | Select-Object Free).Free / 1MB
        
            $UsedMemorybySql = Invoke-SqlCmd -Query "SELECT physical_memory_in_use_kb/1024 AS sqlusedmemory FROM sys.dm_os_process_memory;"  
            $availableMemorybySql = Invoke-SqlCmd -Query "SELECT available_commit_limit_kb/1024 AS sqlavailmemory FROM sys.dm_os_process_memory;"
            $totalMemoryforSQL = $availableMemorybySql.sqlavailmemory + $UsedMemorybySql.sqlusedmemory

            $allDriveSpace = Get-WmiObject -Class win32_logicaldisk -ComputerName $server_name
    
            $totalAvailableSpace = 0;
            $totalSpace = 0;
    
            foreach ($drive in $allDriveSpace) {
                $totalAvailableSpace += $drive.FreeSpace
                $totalSpace += $drive.Size
            }
            $totalAvailableSpace = $totalAvailableSpace / 1MB 
            $totalSpace = $totalSpace / 1MB
            

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
            $serverVersion = $server.Information.VersionString
            $productLevel = $server.Information.ProductLevel
            
            $FullTextSearchEnabled = $server.Information.IsFullTextInstalled
            $SqlLanguage = $server.Information.Language
            $SqlEdition = $server.Information.Edition
            $dbCollationName = $server.Information.Collation
            $CLR = "v" + $PSVersionTable.CLRVersion.Major.ToString() + "." + $PSVersionTable.CLRVersion.Minor.ToString() + "." + $PSVersionTable.CLRVersion.Build.ToString()

            $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop
            $processID = $sql_services.ProcessID[0]

            if ($processID -ne "") {
                $SQLPort = (((netstat -ano | findstr $processID)[0].ToString().Split('') | where { $_ -ne "" })[1].Split(":"))[1]
            }
            else {
                $SQLPort = "N/A"
            }
        
           
            $CPUCore = (Get-CIMInstance -Class 'CIM_Processor').NumberOfCores
            $RAM = (systeminfo | Select-String 'Total Physical Memory:').ToString().Split(':')[1].Trim()
        
            $ServerName = $env:COMPUTERNAME
            $drives = Get-WmiObject Win32_LogicalDisk -ComputerName $ServerName | Select -Property Size
            foreach ($drive  in $drives) {
                $drivename = $drive. -split ":"
                if (($drivename -ne "A") -and ($drivename -ne "B")) {
                    $totalspace += [int]($drive.Size / 1GB)
                }
            }
            $RAMGB = [int]($RAM.Split(' ')[0].Trim() / 1024) 
            

            $numberFormat = (Invoke-Sqlcmd -Query "select format(987654321.00, 'N', 'en-us' );").Column1

            $sysInfo = Invoke-Sqlcmd -Query "SELECT * FROM sys.dm_os_sys_info"

            $sockets = $sysInfo.socket_count
            $coresPerSocket = $sysInfo.cores_per_socket
            $logicalProcessors = (Get-CimInstance Win32_ComputerSystem) | Select  NumberOfLogicalProcessors
            $sqlLicense = "SQL Server detected " + $sockets + " sockets with " + $coresPerSocket.NumberOfLogicalProcessors + " cores per socket and " + $logicalProcessors.NumberOfLogicalProcessors + " logical processors per socket, " + $logicalProcessors.NumberOfLogicalProcessors + " total logical processors; using 4 logical processors based on SQL Server licensing."

            $sqlHardwareDetails = (Test-DbaMaxDop -SqlInstance $env:COMPUTERNAME | Select-Object *)[0]
            $dbMaxDOP = $sqlHardwareDetails.DatabaseMaxDop
            $NumaNodes = $sqlHardwareDetails.NumaNodes
            $costThresholdDOP = (Invoke-Sqlcmd -Query "SELECT value FROM sys.configurations WITH (NOLOCK) WHERE name IN ('cost threshold for parallelism')").value
        
            $ServerType = (Get-WmiObject -ComputerName $ServerName -class Win32_ComputerSystem | Select -Property Model).Model

            
            $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST"
            $isDatabaseMailEnabled = $server.Configuration.DatabaseMailEnabled.ConfigValue
            $databaseMailStatus = $server.Configuration.DatabaseMailEnabled.RunValue
            $FileStreamConfigLevel = $server.Configuration.FilestreamAccessLevel.ConfigValue
            $FileStreamAccessLevel = $server.Configuration.FilestreamAccessLevel.RunValue
            $FileStreamFileSize = 0;
            $FileStreamFilePath = "Filestream Not enabled in DB.";
            
            $isClrEnabled = ( Invoke-Sqlcmd -query "SELECT * FROM sys.configurations WHERE name = 'clr enabled'" ).value  
            $output += "`n isClrEnabled: $isClrEnabled"
            $output += "`n================================================"
            $output += "`n Windows Details"
            $output += "`n================================================"
            $output += "`n Windows Version:" + $WindowsVersion
            $output += "`n Total Memory In Use: " + $UsedMemorybySql.sqlusedmemory + "MB"
            $output += "`n Hard Drive C Drive: [" + $used + "/" + $free + "]"
            $output += "`n Total Memory Allocated: " + $totalMemoryforSQL + "MB"
            $output += "`n Available Physical Memory: $totalAvailableSpace"
            $output += "`n Total Physical Memory: $totalSpace"
            $output += "`n Recommended [SQL Server] : CPUCore=" + $CPUCore + ",RAM=" + $RAMGB + " GB,DISK=" + $totalspace + " GB"
            $output += "`n================================================"
            $output += "`n Sql Server Details"
            $output += "`n================================================"
            $output += "`n Server Name : " + $ServerName
            $output += "`n SqlProductDetails: $SqlProductDetails"
            $output += "`n serverVersion: $serverVersion"
            $output += "`n FullTextSearchEnabled: $FullTextSearchEnabled"
            $output += "`n SqlLanguage: $SqlLanguage"
            $output += "`n SqlEdition: $SqlEdition"
            $output += "`n dbCollationName: $dbCollationName"
            $output += "`n CLR Version $CLR"
            $output += "`n productLevel: $productLevel"
            $output += "`n PORT: $SQLPort"
            $output += "`n Number Format(en-us): $numberFormat"
            $output += "`n SQL License: $sqlLicense"
            $output += "`n Max DOP: $dbMaxDOP"
            $output += "`n NUMA Nodes: $NumaNodes"
            $output += "`n Cost of Threshold DOP: $costThresholdDOP"
            $output += "`n Server TYPE: $ServerType"
            if ($databaseExist) {
                $output += "`n dbName: $database"
                $output += "`n isDatabaseMailEnabled: $isDatabaseMailEnabled"
                $output += "`n databaseMailStatus: $databaseMailStatus"
                $output += "`n FileStreamConfigLevel: $FileStreamConfigLevel"
                $output += "`n FileStreamAccessLevel: $FileStreamAccessLevel"
                $output += "`n FILESTREAM FILE Path: $FileStreamFilePath"
                $output += "`n FILESTREAM FILE Size: $FileStreamFileSize"
    
                $backupPath = ($server.Settings.BackupDirectory).ToString() + $database + ".bak"
                $output += "`n backupPath: $backupPath"
                if ($FileStreamConfigLevel -ne 0) {
                    try {
                        $dbfiles = Invoke-Sqlcmd -Query "Use $database Select * from sys.database_files;"
                        foreach ($file in $dbfiles) {
                            if ($file.type_desc -eq "FILESTREAM") {
                                $FileStreamFileSize = $file.size
                                $FileStreamFilePath = $file.physical_name
                            }
                        }   
                    }
                    catch {
                        "Database Not Found!"
                    }
                }
            }
            else {
                "Database Not Found!"
            }
            foreach ($db in $server.Databases) {
                if ($db.Name -eq $database) {
                    $dbRecoveryModel = $db.RecoveryModel
                    $output += "`n dbRecoveryModel: $dbRecoveryModel"
                    $dbCompatibilityLevel = $db.CompatibilityLevel
                    $output += "`n dbCompatibilityLevel: $dbCompatibilityLevel"
                    $dbLastBackupDate = $db.LastBackupDate.ToString("MM/dd/yyyy")
                    if ($dbLastBackupDate -eq "01/01/0001") {
                        $output += "`n dbLastBackupDate: N/A"
                    }
                    else {
                        $output += "`n dbLastBackupDate: $dbLastBackupDate"
                    }
                }
            }

            $folder = $server.Information.MasterDBLogPath
            $authenticationMode = $server.Settings.LoginMode
            $output += "`n Auth Mode: $authenticationMode"
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
        return $output | Format-List
    }
}
Get-MachineDetails