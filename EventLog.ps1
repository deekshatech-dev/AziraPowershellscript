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

function Get-SqlErrorLog {
    
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
        try {
            $event_log = (Get-EventLog -LogName "application" -EntryType Error | Where-Object { ($_.source -like "*SQL*") -or ($_.source -like "*ssrs*") -or ($_.source -like "*ssas*") } ) | Format-List
            $output += ($event_log | Out-String).ToString()
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

Get-SqlErrorLog