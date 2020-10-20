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
        
        Import-Module SQLPS
    }
    Process {   
        
        $servername = 'NOOBITAXD'
        $server_name = $env:COMPUTERNAME
        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        
        $folder = $server.Information.MasterDBLogPath
        $folder

        $v = 14
        $rs = (Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer  -class __Namespace).Name
        $nspace = "root\Microsoft\SQLServer\ReportServer\$rs\v$v\Admin"
        $RSServers = Get-WmiObject -Namespace $nspace -class MSReportServer_ConfigurationSetting -ComputerName $servername -ErrorVariable perror -ErrorAction SilentlyContinue
        
        foreach ($r in $RSServers) {
    
            $ssrsInstanceNamet = $r.InstanceName
            $ssrsVers = $r.version
            $ssrsDB = $r.DatabaseName
            $vPath = $r.VirtualDirectoryReportServer
            $urls = $r.ListReservedUrls() 
            $urls = $urls.UrlString[0]
            $urls = $urls.Replace('+', $servername) + "/$vPath"

            $ssrsDBmdfPath = $folder + "\" + $ssrsDB +".mdf"
            $ssrsDBldfPath = $folder + "\" + $ssrsDB +"_log.ldf"
            
            $ssrsTempDBldfPath = $folder + "\" + $ssrsDB +"TempDB.mdf"
            $ssrsTempDBldfPath = $folder + "\" + $ssrsDB +"TempDB_log.ldf"
        }
        foreach ($file in Get-ChildItem $folder) {
            if ($file.Name -eq "$ssrsDB.mdf") {
                $ssrsDBmdfSize  = ($file.Size/1000000).ToString() + " MB"
            }
            if ($file.Name -eq "$ssrsDB_log.ldf") {
                $ssrsDBldfSize  = ($file.Size/1000000).ToString() + " MB"
            }
            if ($file.Name -eq "$ssrsDBTempDB.mdf") {
                $ssrsTempDBmdfSize  = ($file.Size/1000000).ToString() + " MB"
            }
            if ($file.Name -eq "$ssrsDBTempDB_log.ldf") {
                $ssrsTempDBldfSize  = ($file.Size/1000000).ToString() + " MB"
            }
        }
    }
    End {
    }
}

Get-MachineDetails