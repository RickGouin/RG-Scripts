###############################
# Script to Report Volumes not 
# using the Recommended Storage Profile
#
# www.rickgouin.com
# 01/04/2014
###############################
 
# Storage Center User to run script
$user = "Admin"
 
# Storage Center Password
$pass = ConvertTo-SecureString "mmm" -AsPlainText -Force
 
# Storage Center Host Name or IP Address
$schost = "0.0.0.0"
 
#################################
# Nothing to edit below
#################################
 
#grab a list of loaded snapins
$list = Get-PSSnapin
$added = $false
 
#Loop through the list of snapins looking for the Compellent snapin
foreach ($item in $list)            
{            
    if ($item.Name -eq "Compellent.StorageCenter.PSSnapIn")            
    {
    $added = $true
  }            
}  
#No snapin detected, load it.
if ($added -eq $FALSE)            
    {$tmp = Add-PSSnapin Compellent.StorageCenter.PSSnapIn} 
#Connect to the SC
$connection = Get-SCConnection -HostName $schost -User $user -Password $pass -Save $schost -Default      

Write-Host "`n Volumes not using the Recommended profile: "
#Get a list of all the volumes that aren't using the storage profile called "Recommended"
get-scvolume | where-object {$_.StorageProfileName -ne "Recommended"}