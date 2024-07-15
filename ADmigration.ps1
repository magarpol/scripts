# Import the CSV file
$csvData = Import-Csv -Path 'C:\mydata.csv' -encoding UTF8
#Fields CSV
#Vorname (bÃ¼rgerlich),"Nachname (bÃ¼rgerlich)","E-Mail","Abteilung","Position","Gesellschaft","Team","Name (bevorzugt)","Status","FÃ¼hrungskraft","Austrittsdatum","Telefonnummer (geschÃ¤ftlich)"

$NotFoundList = @()

Foreach($row in $csvData){
    #Fields AD
    #GivenName, Surname, mail, Department, Title, Company, Team, DisplayName, Status, Manager, ExitDate, Mobile
    $User = Get-ADUser -Filter "mail -eq '$($row.'E-mail')'" -GivenName, Surname, mail, Department, Title, Company, Team, DisplayName, Status, Manager, ExitDate, Mobile

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
	if ($user.mail -ne $($row.'E-Mail')) {
            $SetADUserSplatHash.Add('mail',$($row.'E-Mail'))
        }
        if ($user.Department -ne $($row.Abteilung)) {
            $SetADUserSplatHash.Add('Department',$($row.Abteilung))
        }
        if ($user.Title -ne $($row.Position)) {
            $SetADUserSplatHash.Add('Title',$($row.Position))
        }
	if ($user.Company -ne $($row.Gesellschaft)) {
            $SetADUserSplatHash.Add('Company',$($row.Gesellschaft))
        }
        if ($user.Team -ne $($row.Team)) {
            $SetADUserSplatHash.Add('Team',$($row.Team))
        }
	    if ($user.DisplayName -ne $($row.'Name (bevorzugt)')) {
            $SetADUserSplatHash.Add('DisplayName',$($row.'Name (bevorzugt)'))
        }
	if ($user.Status -ne $($row.Status)) {
            $SetADUserSplatHash.Add('Status',$($row.Status))
        }
        if ($user.Manager -ne $($row.Führungskraft)) {
            $SetADUserSplatHash.Add('Manager',$($row.Führungskraft))
        }
        if ($user.ExitDate -ne $($row.Austrittsdatum)) {
            $SetADUserSplatHash.Add('ExitDate',$($row.Austrittsdatum))
        }
        if ($user.Mobile -ne $($row.'Telefonnummer (geschäftlich)')) {
            $SetADUserSplatHash.Add('Mobile',$($row.'Telefonnummer (geschäftlich)'))	
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
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
