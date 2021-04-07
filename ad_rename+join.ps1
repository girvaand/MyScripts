### Rename Windows Machine & Domain Join Powershell Script v0.1, 3/22/16
### Author: Tyler Bradford - about.me/tylerbradford

## General (personal) Prefs & Script-wide Variables

$host.ui.RawUI.ForegroundColor = “Green”
$curExPol = Get-ExecutionPolicy -scope CurrentUser

# Prompt for user input re: Script Exec Policy

$title = “Change Execution Policy” 
$message = “Your current Powershell Execution policy is set to $curExPol. 
This script will change this setting to Unrestricted for the duration of the script, 
then restore it upon successfully running. Is this OK?”
$yes = New-Object System.Management.Automation.Host.ChoiceDescription “&Yes”, ` “Continue”
$no = New-Object System.Management.Automation.Host.ChoiceDescription “&No”, ` “Exit (no changes will be made)”
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result)
{
    0 {Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
    }
    1 {Exit
    }
}

## Script Function Body

Write-Host "
************************************************
*********** WINDOWS COMPUTER RENAME ************
************ & DOMAIN JOIN SCRIPT **************
*** need inspiration? https://xkcd.com/910/ ****
************************************************"
""
# Computer rename input

$renamecomputer = $false
DO
{
    Write-Host "Please enter your desired computer name. 
    The Current name is [$env:computername]:"
    $computername = Read-Host
    ""
    if ( $computername -match "ANONYMOUS|AUTHENTICATED USER|BATCH|BUILTIN|CREATOR GROUP|CREATOR GROUP SERVER|CREATOR OWNER CREATOR OWNER|SERVER|DIALUP|DIGEST AUTH|INTERACTIVE|INTERNET|LOCAL|LOCAL SYSTEM|NETWORK|NETWORK SERVICE|NT AUTHORITY|NT DOMAIN|NTLM AUTH|NULL|PROXY|REMOTE INTERACTIVE|RESTRICTED|SCHANNEL AUTH|SELF SERVER|SERVICE|SYSTEM|TERMINAL SERVER|THIS ORGANIZATION|USERS|WORLD" ) { Write-Host "Sorry, you picked a machine name that is not allowed by Microsoft. For a list of these names, see https://support.microsoft.com/en-us/kb/909264 Please try again." }
    if ( $computername -match "\w{2,15}" ) { $renamecomputer = $true }
    if ( $computername -notmatch "\w{2,15}" ) { Write-Host "Sorry, but your computer name is not allowed. See https://support.microsoft.com/en-us/kb/909264 for more details, and try again." }
} 
While ( $renamecomputer -eq $false )

# Domain join & computer rename - Set vars as needed

$domain = "domain.tld"
$ou = "OU=computers,DC=domain,DC=tld"
$credentials = New-Object System.Management.Automation.PsCredential("domain\admin-user", (ConvertTo-SecureString "domain-admin-pwd" -AsPlainText -Force))

Write-Host "Adding $computername to $domain in $ou. Is this ok?"

$answer = Read-Host "Yes or No"
while("yes","no" -notcontains $answer)
{
	$answer = Read-Host "Yes or No"
}
if ($answer -eq "no") { exit }

Add-Computer -DomainName $domain -Credential $credentials -OUPath $ou
if ( $? -eq "0" ) { $joined = $true }
if ($renamecomputer -eq $true) { Rename-Computer -NewName $computername -DomainCredential $credentials -Force }
if ( $? -eq "0" ) { $renamed = $true }
if ( ($joined -eq $true) -and ($renamed -eq $true) ) { Write-Host "$computername has been joined to $ou. The machine will reboot in 5 seconds." ;
Start-Sleep 5
}

## Reset Local User Env

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy $curExPol

# Reboot

if ( ($joined -ne $true) -and ($renamed -ne $true) ) { Write-Host "Sorry, something went wrong, 
your machine name has not been changed. 
exiting...." ; 
Start-Sleep 3 ; 
Exit 
}
if ( ($joined -ne $true) -and ($renamed -eq $true) ) { Write-Host "Sorry, the domain join *FAILED*, 
but your machine name will be changed (after reboot).
exiting...." ; 
Start-Sleep 3 ; 
Exit 
}
Restart-Computer