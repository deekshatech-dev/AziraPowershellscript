# Required Modules to Import
# Import-Module servermanager 
# Import-Module SqlServer 
# Import-Module SQLPS 
# Import-Module dbatools 

Function Get-PrerequiredModules {
    try {
        Import-Module SqlServer 
        Import-Module SQLPS 
        Import-Module dbatools 
    }
    catch {
        "catch"
        Install-Module dbatools -AllowClobber
        Install-Module SqlServer -AllowClobber
        
    }
}
Get-PrerequiredModules