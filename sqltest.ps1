<#
 .DESCRIPTION
   Outputs the SSL protocols that the client is able to successfully use to connect to a server.
 
 .NOTES
 
   Copyright 2014 Chris Duck
   http://blog.whatsupduck.net
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
     http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 
 .PARAMETER ComputerName
   The name of the remote computer to connect to.
 
 .PARAMETER Port
   The remote port to connect to. The default is 443.
 
 .EXAMPLE
 #>
Function Get-ComputerMemory {
    $mem = Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    return ($mem.Sum / 1MB);
}
Function Get-SQLMaxMemory { 
    $memtotal = Get-ComputerMemory
    $min_os_mem = 2048 ;
    if ($memtotal -le $min_os_mem) {
        Return $null;
    }
    if ($memtotal -ge 8192) {
        $sql_mem = $memtotal - 2048
    }
    else {
        $sql_mem = $memtotal * 0.8 ;
    }
    return [int]$sql_mem ;  
}

function Get-StorageProps {
    $computerName = $env:COMPUTERNAME
    $allDriveSpace = Get-WmiObject -Class win32_logicaldisk -ComputerName $computerName
    
    $totalAvailableSpace = 0;
    $totalSpace = 0;

    foreach ($drive in $allDriveSpace) {
        $totalAvailableSpace += $drive.FreeSpace
        $totalSpace += $drive.Size
    }
    $totalAvailableSpace = $totalAvailableSpace/1MB 
    $totalSpace = $totalSpace/1MB
    "Total: " +$totalSpace + " / Free: " + $totalAvailableSpace 
    # Get-WmiObject -Class win32_logicaldisk -ComputerName $computerName | ft DeviceID, @{Name = "Free Disk Space (GB)"; e = { $_.FreeSpace / 1GB } }, @{Name = "Total Disk Size (GB)"; e = { $_.Size / 1GB } } -AutoSize
    # Get-WmiObject -Class win32_computersystem -ComputerName $computerName | ft @{Name = "Physical Processors"; e = { $_.NumberofProcessors } } , @{Name = "Logical Processors"; e = { $_.NumberOfLogicalProcessors } } , @{Name = "TotalPhysicalMemory (GB)"; e = { [math]::truncate($_.TotalPhysicalMemory / 1GB) } }, Model -AutoSize
    # Get-WmiObject -Class win32_operatingsystem -ComputerName $computerName | ft @{Name = "Total Visible Memory Size (GB)"; e = { [math]::truncate($_.TotalVisibleMemorySize / 1MB) } }, @{Name = "Free Physical Memory (GB)"; e = { [math]::truncate($_.FreePhysicalMemory / 1MB) } } -AutoSize
    # Get-WmiObject -Class win32_operatingsystem -ComputerName $computerName | ft @{Name = "Operating System"; e = { $_.Name } } -AutoSize
    # Get-WmiObject -Class win32_bios -ComputerName $computerName | ft @{Name = "ServiceTag"; e = { $_.SerialNumber } }
}
Get-StorageProps
# Get-SQLMaxMemory