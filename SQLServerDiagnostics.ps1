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
        #$RemoteComputerName
        [Parameter(Mandatory = $true)]
        [string]$database = $args[0]
    )

    Begin {
        $output = ""
        $totalspace = 0
        
    }
    Process {   
        # Import-Module SQLPS
        $erroFile = "./error_log/sqlserverdiagnostics_" + (get-date -f MM_dd_yyyy_HH_mm_ss).ToString() + ".txt"
        $server_name = $env:COMPUTERNAME
        try {
            $output += "`n server_name: $server_name"
            $dbName = $database
            if ($databaseExist) {
                $output += "`n dbName: $dbName"
            }
            $instanceName = "localhost"
            $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
            $databases = $server.Databases
            $databaseExist = $false
            foreach ($db in $databases) {
                If ($db.Name -like $database) {
                    $databaseExist = $true
                }
            }
            if ($databaseExist) {
                
            }
            else {
                $database + " does not Exist!"
            }
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
            $output += "`n TEMPDB Database on C Drive: $tempDbExist"
            $output += "`n MODEL Database on C Drive: $modelDbExist"
            $output += "`n MASTER Database on C Drive: $masterDbExist"
            $output += "`n MSDB Database on C Drive: $MSDbExist"
            $output += "`n TempDB Only Has 1 Data File: $tempdbMoreThanOneFile"
        
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

            $output += "`n modelback: $modelback"
            $output += "`n masterback: $masterback"
            $output += "`n msdbback: $msdbback"
            $output += "`n dbback: $dbback"


            $DbIntegrityCheckDate = $server.Databases[3].ExecuteWithResults("DBCC DBINFO () WITH TABLERESULTS").Tables[0] | Where-Object { $_.Field -eq "dbi_dbccLastKnownGood" }  | Select-Object Value
            $twoWeekBackDate = (Get-Date).AddDays(-14)
        
            $isBackupInTwoWeeks = ($twoWeekBackDate) -LT (Get-Date($DbIntegrityCheckDate.Value))
            if ($isBackupInTwoWeeks -eq $true) {
                $DbIntegrityCheck = "DBCC CHECKDB (Database Integrity check) completed successfully in recent 2 weeks"
            }
            else {
                $DbIntegrityCheck = "DBCC CHECKDB (Database Integrity check) completed successfully in before 2 weeks"
            }
            $output += "`n DbIntegrityCheck: $DbIntegrityCheck"
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

Get-ServerDiagnostics