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
        $ssasInstanceName = "localhost"
        $loadAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices")
        $svr = New-Object Microsoft.AnalysisServices.Server
        $svr.Connect($ssasInstanceName)
        
        $svr.Edition
        $svr.ProductLevel
        $svr.ProductName
        $svr.ServerMode
        $svr.ServerProperties
        

    }
    End {
        return $output | Format-List
    }
}

Get-MachineDetails