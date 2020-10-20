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

function Get-SSRSConiguration {
    
    Param
    (
        # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
    )

    Begin {
        $output = ""
        $v = 12        
        # Import-Module SQLPS
    }
    Process {   
        
        $servername = $env:COMPUTERNAME
        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        
        $folder = $server.Information.MasterDBLogPath
        # $folder

        $rs = (Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer  -class __Namespace).Name
        $nspace = "root\Microsoft\SQLServer\ReportServer\$rs\v$v\Admin"
        $RSServers = Get-WmiObject -Namespace $nspace -class MSReportServer_ConfigurationSetting -ComputerName $servername -ErrorVariable perror -ErrorAction SilentlyContinue
        
        foreach ($r in $RSServers) {
    
            $ssrsInstanceName = $r.InstanceName
            $output += "`n ssrsInstanceName: $ssrsInstanceName"
            $ssrsVers = $r.version
            $output += "`n ssrsVers: $ssrsVers"
            $ssrsDB = $r.DatabaseName
            # $output += "`n ssrsDB: $ssrsDB"
            # $vPath = $r.VirtualDirectoryReportServer
            # $output += "`n vPath: $vPath"
            $urls = $r.ListReservedUrls() 
            $urls = $urls.UrlString[0]
            $urls = $urls.Replace('+', $servername) + "/$vPath"
            $output += "`n urls: $urls "
            
            $ssrsDBmdfPath = $folder + "\" + $ssrsDB +".mdf"
            $output += "`n ssrsDBmdfPath: $ssrsDBmdfPath"
            $ssrsDBldfPath = $folder + "\" + $ssrsDB +"_log.ldf"
            $output += "`n ssrsDBldfPath: $ssrsDBldfPath"
            
            $ssrsTempDBldfPath = $folder + "\" + $ssrsDB +"TempDB.mdf"
            $output += "`n ssrsTempDBldfPath: $ssrsTempDBldfPath"
            $ssrsTempDBldfPath = $folder + "\" + $ssrsDB +"TempDB_log.ldf"
            $output += "`n ssrsTempDBldfPath: $ssrsTempDBldfPath"
        }
        foreach ($file in Get-ChildItem $folder) {
            if ($file.Name -eq "$ssrsDB.mdf") {
                $ssrsDBmdfSize  = ($file.Size/1000000).ToString() + " MB"
                $output += "`n ssrsDBmdfSize: $ssrsDBmdfSize"
            }
            if ($file.Name -eq "$ssrsDB_log.ldf") {
                $ssrsDBldfSize  = ($file.Size/1000000).ToString() + " MB"
                $output += "`n ssrsDBldfSize: $ssrsDBldfSize"
            }
            if ($file.Name -eq "$ssrsDBTempDB.mdf") {
                $ssrsTempDBmdfSize  = ($file.Size/1000000).ToString() + " MB"
                $output += "`n ssrsTempDBmdfSize: $ssrsTempDBmdfSize"
            }
            if ($file.Name -eq "$ssrsDBTempDB_log.ldf") {
                $ssrsTempDBldfSize  = ($file.Size/1000000).ToString() + " MB"
                $output += "`n ssrsTempDBldfSize: $ssrsTempDBldfSize"
            }
        }
    }
    End {
        return $output | Format-List
    }
}

Get-SSRSConiguration