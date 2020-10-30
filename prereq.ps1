# Required Modules to Import
# Import-Module servermanager 
# Import-Module SqlServer 
# Import-Module SQLPS 
# Import-Module dbatools 

Function Get-PrerequiredModules {
    "lol"
    Install-Module -name "dbatools" -AllowClobber
    # Install-Module SQLPS
    # Install-Module SqlServer
    # Install-Module servermanager
}
Get-PrerequiredModules