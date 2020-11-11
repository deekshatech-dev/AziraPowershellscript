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

function Get-ServerDiagnostics {
    
    Param
    (
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
        [Parameter(Mandatory = $false)]
        $showServerName = $args[0],
        [Parameter(Mandatory = $false)]
        $showDbName = $args[1],
        [Parameter(Mandatory = $false)]
        $showtempDbExist = $args[2],
        [Parameter(Mandatory = $false)]
        $showmodelDbExist = $args[3],
        [Parameter(Mandatory = $false)]
        $showmasterDbExist = $args[4],
        [Parameter(Mandatory = $false)]
        $showMSDbExist = $args[5],
        [Parameter(Mandatory = $false)]
        $showtempDbMoreThanOneFile = $args[6],
        [Parameter(Mandatory = $false)]
        $showmodelback = $args[7],
        [Parameter(Mandatory = $false)]
        $showmasterback = $args[8],
        [Parameter(Mandatory = $false)]
        $showmsdbback = $args[9],
        [Parameter(Mandatory = $false)]
        $showdbback = $args[10],
        [Parameter(Mandatory = $false)]
        $showDbIntegrityCheck = $args[11]
    )

    Begin {
        $output = ""
        $totalspace = 0
        if (!$showServerName) {
            if (($showServerName -eq 0)) {
                $showServerName = $false
            } else {
                $showServerName = $true
            }
        }
        if (!$showDbName) {
            if (($showDbName -eq 0)) {
                $showDbName = $false
            } else {
                $showDbName = $true
            }
        }
        if (!$showtempDbExist) {
            if (($showtempDbExist -eq 0)) {
                $showtempDbExist = $false
            } else {
                $showtempDbExist = $true
            }
        }
        if (!$showmodelDbExist) {
            if (($showmodelDbExist -eq 0)) {
                $showmodelDbExist = $false
            } else {
                $showmodelDbExist = $true
            }
        }
        if (!$showmasterDbExist) {
            if (($showmasterDbExist -eq 0)) {
                $showmasterDbExist = $false
            } else {
                $showmasterDbExist = $true
            }
        }
        if (!$showMSDbExist) {
            if (($showMSDbExist -eq 0)) {
                $showMSDbExist = $false
            } else {
                $showMSDbExist = $true
            }
        }
        if (!$showtempDbMoreThanOneFile) {
            if (($showtempDbMoreThanOneFile -eq 0)) {
                $showtempDbMoreThanOneFile = $false
            } else {
                $showtempDbMoreThanOneFile = $true
            }
        }
        if (!$showmodelback) {
            if (($showmodelback -eq 0)) {
                $showmodelback = $false
            } else {
                $showmodelback = $true
            }
        }
        if (!$showmasterback) {
            if (($showmasterback -eq 0)) {
                $showmasterback = $false
            } else {
                $showmasterback = $true
            }
        }
        if (!$showmsdbback) {
            if (($showmsdbback -eq 0)) {
                $showmsdbback = $false
            } else {
                $showmsdbback = $true
            }
        }
        if (!$showdbback) {
            if (($showdbback -eq 0)) {
                $showdbback = $false
            } else {
                $showdbback = $true
            }
        }
        if (!$showDbIntegrityCheck) {
            if (($showDbIntegrityCheck -eq 0)) {
                $showDbIntegrityCheck = $false
            } else {
                $showDbIntegrityCheck = $true
            }
        }
    }
    Process {   
        # Import-Module SQLPS
        $erroFile = "./error_log/sqlserverdiagnostics_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        $server_name = $env:COMPUTERNAME
        try {
            if ($showServerName) {
                $output += "`n server_name: $server_name"
            }
            $dbName = "PowershellDB"
            if ($showDbName) {
                $output += "`n dbName: $dbName"
            }
            $instanceName = "localhost"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        
            $folder = $server.Information.MasterDBLogPath
            $tempFileCount = 0
            $tempDbExist = "Does Not Exists"
            $modelDbExist = "Does Not Exists"
            $masterDbExist = "Does Not Exists"
            $MSDbExist = "Does Not Exists"
        
            foreach ($file in Get-ChildItem $folder) {
                if ($file.Name -Contains "tempdb") {
                    $tempDbExist = "Exists: TempDB frequently grows unpredictably, putting your server at risk of running out of C drive space and crashing hard. C is also often much slower than other drives, so performance may be suffering."
                    $global:tempFileCount++
                }
                if ($file.Name -Contains "model") {
                    $modelDbExist = "Exists: Putting system databases on the C drive runs the risk of crashing the server when it runs out of space."
                }
                if ($file.Name -Contains "master") {
                    $masterDbExist = "Exists: Putting system databases on the C drive runs the risk of crashing the server when it runs out of space."
                }
                if ($file.Name -Contains "MSDB") {
                    $MSDbExist = "Exists: Putting system databases on the C drive runs the risk of crashing the server when it runs out of space."
                }
            }
            if ($empFileCount -GT 1) {
                $tempdbMoreThanOneFile = "TempDB is only configured with one data file. More data files are usually required to alleviate SGAM contention"
            }
            else {
                $tempdbMoreThanOneFile = "TempDB is configured with more than one data file. More data files are usually required to alleviate SGAM contention"
            }


            if ($showtempDbExist) {
                $output += "`n tempDbExist: $tempDbExist"
            }
            if ($showmodelDbExist) {
                $output += "`n modelDbExist: $modelDbExist"
            }
            if ($showmasterDbExist) {
                $output += "`n masterDbExist: $masterDbExist"
            }
            if ($showMSDbExist) {
                $output += "`n MSDbExist: $MSDbExist"
            }
            if ($showtempDbMoreThanOneFile) {
                $output += "`n tempdbMoreThanOneFile: $tempdbMoreThanOneFile"
            }
            
            
            
            
        
            $backupFolder = $server.Settings.BackupDirectory        

            $modelback = "Never"
            $masterback = "Never"
            $msdbback = "Never"
            $dbback = "Never"

            foreach ($file in Get-ChildItem $backupFolder) {
                if ($file.Name -Contains "model") {
                    $modelback = $file.LastWriteTime
                }
                if ($file.Name -Contains "master") {
                    $masterback = $file.LastWriteTime
                }
                if ($file.Name -Contains "MSDB") {
                    $msdbback = $file.LastWriteTime
                }
                if ($file.Name -Contains $dbName) {
                    $dbback = $file.LastWriteTime
                }
            }
            if ($showmodelback) {
                $output += "`n modelback: $modelback"
            }
            if ($showmasterback) {
                $output += "`n masterback: $masterback"
            }
            if ($showmsdbback) {
                $output += "`n msdbback: $msdbback"
            }
            if ($showdbback) {
                $output += "`n dbback: $dbback"
            }
            $DbIntegrityCheckDate = $server.Databases[3].ExecuteWithResults("DBCC DBINFO () WITH TABLERESULTS").Tables[0] | Where-Object { $_.Field -eq "dbi_dbccLastKnownGood" }  | Select-Object Value
            $twoWeekBackDate = (Get-Date).AddDays(-14)
        
            $isBackupInTwoWeeks = ($twoWeekBackDate) -LT (Get-Date($DbIntegrityCheckDate.Value))
            if ($isBackupInTwoWeeks -eq $true) {
                $DbIntegrityCheck = "DBCC CHECKDB (Database Integrity check) completed successfully in recent 2 weeks"
            }
            else {
                $DbIntegrityCheck = "DBCC CHECKDB (Database Integrity check) completed successfully in before 2 weeks"
            }
            if ($showDbIntegrityCheck) {
                $output += "`n DbIntegrityCheck: $DbIntegrityCheck"
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

Get-ServerDiagnostics