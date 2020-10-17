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

function Get-MachineDetails
{
    
    Param
    (
       # [Parameter(Mandatory=$false)]
        #$RemoteComputerName
    )

    Begin
    {
        $output=""
        $totalspace = 0
    }
    Process
    {   
        $server_name = $env:COMPUTERNAME

        $WindowsVersion = (systeminfo | Select-String 'OS Version:')[0].ToString().Split(':')[1].Trim()
        $output += "`nWindows Version:" + $WindowsVersion
        Import-Module SQLPS
        $SqlProductDetails = Invoke-SqlCmd -query "select @@version" -ServerInstance "localhost"

        $instanceName = "localhost"
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
        $serverVersion = $server.Information.VersionString

        $productLevel = $server.Information.ProductLevel

        $FullTextSearchEnabled = $server.Information.IsFullTextInstalled

        $TotalPhysicalMemory = $server.Information.PhysicalMemory
         
        $SqlLanguage = $server.Information.Language

        $SqlEdition = $server.Information.Edition

        $SqlCollationName = $server.Information.Collation

        $sql_services = Get-WmiObject -Query "select * from win32_service where PathName like '%%sqlservr.exe%%'" -ComputerName "$server_name" -ErrorAction Stop

        $tempDbLdfPath = $server.Information.MasterDBLogPath + "_log.ldf"

        $tempDbmdfPath = $server.Information.MasterDBPath + ".mdf"
    }
    End
    {
        return $output | Format-List
    }
}

Get-MachineDetails