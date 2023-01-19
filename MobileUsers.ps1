$credentials = Get-Credential -Credential helpdesk@phcenters.com
    Write-Output "Getting the Exchange Online cmdlets"
 
    $session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
        -ConfigurationName Microsoft.Exchange -Credential $credentials `
        -Authentication Basic -AllowRedirection
    Import-PSSession $session
 
$csv = "C:\MobileDevices.csv"
$results = @()
$mailboxUsers = get-mobiledevice -resultsize unlimited
$mobileDevice = @()
 
foreach($user in $mailboxUsers)
{
$UPN = $user.UserPrincipalName
$displayName = $user.DisplayName
 
$mobileDevices = Get-MobileDeviceStatistics -Identity $Device.Guid.toString()
       
      foreach($mobileDevice in $mobileDevices)
      {
          Write-Output "Getting info about a device for $displayName"
          $properties = @{
          Name = $user.name
          UPN = $UPN
          DisplayName = $displayName
          FriendlyName = $mobileDevice.FriendlyName
          ClientType = $mobileDevice.ClientType
          ClientVersion = $mobileDevice.ClientVersion
          DeviceId = $mobileDevice.DeviceId
          DeviceMobileOperator = $mobileDevice.DeviceMobileOperator
          DeviceModel = $mobileDevice.DeviceModel
          DeviceOS = $mobileDevice.DeviceOS
          DeviceTelephoneNumber = $mobileDevice.DeviceTelephoneNumber
          DeviceType = $mobileDevice.DeviceType
          FirstSyncTime = $mobileDevice.FirstSyncTime
          UserDisplayName = $mobileDevice.UserDisplayName
          }
          $results += New-Object psobject -Property $properties
      }
}
 
$results | Select-Object Name,UPN,FriendlyName,DisplayName,ClientType,ClientVersion,DeviceId,DeviceMobileOperator,DeviceModel,DeviceOS,DeviceTelephoneNumber,DeviceType,FirstSyncTime,UserDisplayName | Export-Csv -notypeinformation -Path $csv
 
Remove-PSSession $session
