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

function Get-SSASConfiguration {
    
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
        $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
        $output += "`n `nWindows Server:" + $env:COMPUTERNAME
        $output += "`n `nWindows Version:" + $WindowsVersion

        $ssasInstanceName = "localhost"
        $loadAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
        $svr = New-Object Microsoft.AnalysisServices.Server
        $svr.Connect($ssasInstanceName)
        
        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        $serverVersion = $server.Information.VersionString
        $output += "`nssqlVersion: $serverVersion"

        # To create a new DB
        # $svr.databases.add("SSASDB")
        # $DB = $svr.databases.item("SSASDB")
        # $DB.update()
        # $DB.description = "Testing SSAS DB addition"
        # $DB.update()


        $ssasVersion = $svr.Version
        $output += "`nssasVersion: $ssasVersion"
        $ssasServerMode = $svr.ServerMode
        $output += "`nssasServerMode: $ssasServerMode"
        $ssasCollation = $svr.Collation
        $output += "`nssasCollation: $ssasCollation"
        $ssasCubes = $svr.Cubes
        $output += "`nssasCubes: $ssasCubes"
        $ssasEdition = $svr.Edition
        $output += "$ssasEdition"
        $ssasServerMode = $svr.ServerMode

    }
    End {
        return $output | Format-List
    }
}

Get-SSASConfiguration