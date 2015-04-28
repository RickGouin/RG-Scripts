###############################
# Generic Script to take a replay
# and then mount it up to a server
# 
# Similar to the Push2Tape sample script
# except takes a new replay instead
# of just using the most recent one.
#
# www.rickgouin.com
# 04/28/2014
###############################

### Enter the name of the server object from the Compellent that you are mapping the volume to. ##
### Double check spelling, case, and any spaces.  It has to be the same as Compellent displays. ##
$servername = "Servername"
### Enter the name of the LUN from the Compellent that you are mapping. ##
$volumename = "Volumename"
### Enter the drive letter or path you want to mount the drive to. ###
$accesspath = "M:"
# Storage Center User to run script
$user = "username"
# Storage Center Password (stored in clear text for this script)
$pass = ConvertTo-SecureString "password" -AsPlainText -Force
# Storage Center Host Name or IP Address
$schost = "192.168.1.5"
#######################

#### This section loads the CML Powershell Snapin #######
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

######### 
# This section connects to the Compellent, 
# creates a new replay, and maps it up.
#########

#Connect to the storage center
$connection = Get-SCConnection -HostName $schost -User $user -Password $pass -Save $schost -Default

#Get the volume we want to take a replay of
$SCVolume = Get-SCVolume -Name $volumename
if ($SCVolume -eq $null)
{
	Write-Host "Unable to find volume $volumename on Storage Center $schost!" -ForegroundColor Red
	break;
}

#Take the replay.  Set to expire in 1 day (1440 minutes)
$NewReplay = New-SCReplay -SourceSCVolume $SCVolume -MinutesToLive 1440 -Description "Taken by Rickgouin.com Replay Script"

# Get Server Info
$scserver = Get-SCServer -Name $servername
if ($scserver -eq $null)
{
	Write-Host "Unable to find server $servername on Storage Center $schost!" -ForegroundColor Red
	break;
}

# Create View
$newreplayname = "View of Volume ID " + $NewReplay.Index
$replayview = New-SCVolume -SourceSCReplay $NewReplay -Name $newreplayname

# Map View to server
New-SCVolumeMap -SCVolume $replayview -SCServer $scserver -SinglePath

################# 
#This section mounts the Volume in Windows.
#Must run from a system with sufficient rights on the target. 
#################

# Rescan Server
Rescan-CMLDiskDevice -Server $servername -RescanDelay 5

# Add Access Path
Add-CMLVolumeAccessPath -DiskSerialNumber $replayview.SerialNumber -Server $servername -AccessPath $accesspath

# Give the system a few seconds to catch up
Start-Sleep -Seconds 10

### Do whatever you want with this volume here ####
### SQL Tasks, Backup Tasks, etc. #################


########### When you are done, cleanup ##################
# Remove the view volume on the Compellent
Remove-SCVolume -SCVolume $replayview -SkipRecycleBin -Confirm:$false

# Rescan disks on the server
Rescan-DiskDevice -Server $servername -RescanDelay 5
