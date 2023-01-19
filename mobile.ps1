#Get all mobile devices in the org
$MobiledeviceList = Get-MobileDevice
$csv = "C:\MobileDevices.csv"
$results = @()

foreach ($Device in $MobileDeviceList) {
    $Stats = Get-MobileDeviceStatistics -Identity $Device.Guid.toString()
    [PSCustomObject]
    $properties=@{
        Identity              = $Device.Identity -replace "\\.+"
        DeviceType            = $Device.DeviceType
        DeviceOS              = $Device.DeviceOS
        LastSuccessSync       = $Stats.LastSuccessSync
        LastSyncAttemptTime   = $Stats.LastSyncAttemptTime
        LastPolicyUpdateTime  = $Stats.LastPolicyUpdateTime
        LastPingHeartbeat     = $Stats.LastPingHeartbeat
        ClientType            = $Stats.ClientType
    }  
    $results += New-Object psobject -Property $properties
}
$results | Select-Object Identity,DeviceType,DeviceOS,LastSuccessSync,LastSyncAttemptTime,LastPolicyUpdateTime,LastPingHeartbeat,ClientType | Export-csv notypeinformation -path $csv