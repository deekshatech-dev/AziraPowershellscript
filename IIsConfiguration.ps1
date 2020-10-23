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

function Get-IIsConfiguration
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
        Import-Module servermanager
        
        # $installDetails = Get-WindowsFeature -ComputerName $server_name
        # Get-WindowsOptionalFeature -Online | where { ($_.FeatureName -like “IIS-*”) -AND ($_.State -eq “Enabled”) }
        # Get-WindowsOptionalFeature -Online | where { ($_.FeatureName -like "IIS-*") }
    }
    End
    {
        return $output | Format-List
    }
}

Get-IIsConfiguration