# Import the CSV file
$csvData = Import-Csv -Path 'C:\mydata.csv'

$NotFoundList = @()

Foreach($row in $csvData){

    $User = Get-ADUser -Filter "mail -eq '$($row.'E-mail')'" -Properties DisplayName, Department, Title, Mobile, Mail

    $SetADUserSplatHash = @{
        Identity = $User.sAMAccountName
    }

    if ($user) {
        if ($user.GivenName -ne $($row.'Vorname (bürgerlich)')) {
            $SetADUserSplatHash.Add('GivenName',$($row.'Vorname (bürgerlich)')) 
        }
        if ($user.Surname -ne $($row.'Nachname (bürgerlich)')) {
            $SetADUserSplatHash.Add('Surname',$($row.'Nachname (bürgerlich)'))
        }
	    if ($user.DisplayName -ne $($row.'Name (bevorzugt)')) {
            $SetADUserSplatHash.Add('DisplayName',$($row.'Name (bevorzugt)'))
        }
        if ($user.Department -ne $($row.Abteilung)) {
            $SetADUserSplatHash.Add('Department',$($row.Abteilung))
        }
        if ($user.Title -ne $($row.Position)) {
            $SetADUserSplatHash.Add('Title',$($row.Position))
        }
        if ($user.Mobile -ne $($row.'Telefonnummer (geschäftlich)')) {
            $SetADUserSplatHash.Add('Mobile',$($row.'Telefonnummer (geschäftlich)'))
        }
		if ($user.mail -ne $($row.'E-Mail')) {
            $SetADUserSplatHash.Add('mail',$($row.'E-Mail'))
        }
        Set-ADUser @SetADUserSplatHash  -WhatIf
    }
    else {
        $NotFoundList += $row
    }
}

$NotFoundList

#Press any key before closing the PowerShell window
Write-Host "Press any key to close this window..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
