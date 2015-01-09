###############################
# Powershell Script to Report Unmapped Volumes in Compellent
#
# www.rickgouin.com
###############################
 
# Storage Center User to run script
$user = "Admin"
 
# Storage Center Password
$pass = ConvertTo-SecureString "YourPasswordHere" -AsPlainText -Force
 
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
 
#This array will hold volumes that have mappings          
$volumes = @()
 
#Connect to the SC
$connection = Get-SCConnection -HostName $schost -User $user -Password $pass -Save $schost -Default     
 
#This variable will hold all volume mappings
$volumemappings = get-scvolumemap 
 
#Add volumeindex of each volume that has a mapping to the array we created earlier          
foreach($volumemapping in $volumemappings)            
{            
  $volumes += $volumemapping.volumeindex            
}                       
 
#Get a list of all the volumes.  If there is a volume that isn't in our list, that means it doesn't have a mapping.  Thats the output we want.
get-scvolume | where-object {($volumes -notcontains $_.Index )}