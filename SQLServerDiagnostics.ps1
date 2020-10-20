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
        Import-Module SQLPS

        $server_name = $env:COMPUTERNAME
        $output += "server_name: $server_name"
        $dbName = "PowershellDB"
        $output += "dbName: $dbName"
        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        
        $folder = $server.Information.MasterDBLogPath
        Get-SqlBackupHistory -ServerInstance "localhost" -DatabaseName "PowershellDB"
        $tempFileCount = 0
        foreach ($file in Get-Children $folder) {
             if($file.Name -Contains "tempdb"){
                 $tempDbExist = "Exists: TempDB frequently grows unpredictably, putting your server at risk of running out of C drive space and crashing hard. C is also often much slower than other drives, so performance may be suffering."
                 $global:tempFileCount++
             }
             if($file.Name -Contains "model"){
                 $modelDbExist = "Exists: Putting system databases on the C drive runs the risk of crashing the server when it runs out of space."
             }
             if($file.Name -Contains "master"){
                 $masterDbExist = "Exists: Putting system databases on the C drive runs the risk of crashing the server when it runs out of space."
             }
             if($file.Name -Contains "MSDB"){
                 $MSDbExist ="Exists: Putting system databases on the C drive runs the risk of crashing the server when it runs out of space."
             }
        }
        if(tempFileCount -GT 1){
            $tempdbMoreThanOneFile = "TempDB is only configured with one data file. More data files are usually required to alleviate SGAM contention"
        }
        else{
            $tempdbMoreThanOneFile = "TempDB is configured with more than one data file. More data files are usually required to alleviate SGAM contention"
        }
        $output += "tempDbExist: $tempDbExist"
        $output += "modelDbExist: $modelDbExist"
        $output += "masterDbExist: $masterDbExist"
        $output += "MSDbExist: $MSDbExist"
        $output += "tempdbMoreThanOneFile: $tempdbMoreThanOneFile"
        
        $backupFolder = $server.Settings.BackupDirectory        

        $modelback = "Never"
        $masterback = "Never"
        $msdbback = "Never"
        $dbback = "Never"

        foreach ($file in Get-ChildItem $backupFolder) {
            if($file.Name -Contains "model"){
                $modelback = $file.LastWriteTime
            }
            if($file.Name -Contains "master"){
                $masterback = $file.LastWriteTime
            }
            if($file.Name -Contains "MSDB"){
                $msdbback = $file.LastWriteTime
            }
            if($file.Name -Contains $dbName){
                $dbback = $file.LastWriteTime
            }
        }

        $output += "modelback: $modelback"
        $output += "masterback: $masterback"
        $output += "msdbback: $msdbback"
        $output += "dbback: $dbback"


        $DbIntegrityCheckDate = $server.Databases[3].ExecuteWithResults("DBCC DBINFO () WITH TABLERESULTS").Tables[0] | Where-Object {$_.Field -eq "dbi_dbccLastKnownGood"}  | Select-Object Value
        $twoWeekBackDate = (Get-Date).AddDays(-14)
        
        $isBackupInTwoWeeks = ($twoWeekBackDate) -LT (Get-Date($DbIntegrityCheckDate.Value))
        if($isBackupInTwoWeeks -eq $true){
            $DbIntegrityCheck = "DBCC CHECKDB (Database Integrity check) completed successfully in recent 2 weeks"
        }
        else{
            $DbIntegrityCheck = "DBCC CHECKDB (Database Integrity check) completed successfully in before 2 weeks"
        }
        $output+= "DbIntegrityCheck: $DbIntegrityCheck"
    }
    End {
        return $output | Format-List
    }
}

Get-MachineDetails