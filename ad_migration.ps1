# Import the CSV file
$csvData = Import-Csv -Path 'script path' -Encoding UTF8

# Fields CSV
# Vorname (bürgerlich), Nachname (bürgerlich), E-Mail, Abteilung, Position, Gesellschaft, Name (bevorzugt), Team, Telefonnummer (geschäftlich), Führungskraft

$NotFoundList = @()

foreach ($row in $csvData) {
    # Fields AD
    # GivenName, Surname, mail, Department, Title, Company, DisplayName, Manager, Mobile
    $User = Get-ADUser -Filter "mail -eq '$($row.'E-Mail')'" -Properties GivenName, Surname, mail, Department, Title, Company, DisplayName, Manager, Mobile

    if ($User) {
        Write-Host "Processing user: $($User.mail)"

        $SetADUserSplatHash = @{
            Identity = $User.sAMAccountName
        }

        if ($User.GivenName -ne $($row.'Vorname (bürgerlich)')) {
            $SetADUserSplatHash.Add('GivenName', $($row.'Vorname (bürgerlich)'))
            Write-Host "Updating GivenName: '$($User.GivenName)' -> '$($row.'Vorname (bürgerlich)')'"
        }
        if ($User.Surname -ne $($row.'Nachname (bürgerlich)')) {
            $SetADUserSplatHash.Add('Surname', $($row.'Nachname (bürgerlich)'))
            Write-Host "Updating Surname: '$($User.Surname)' -> '$($row.'Nachname (bürgerlich)')'"
        }
        if ($User.mail -ne $($row.'E-Mail')) {
            $SetADUserSplatHash.Add('mail', $($row.'E-Mail'))
            Write-Host "Updating mail: '$($User.mail)' -> '$($row.'E-Mail')'"
        }
        if ($User.Department -ne $($row.Abteilung)) {
            $SetADUserSplatHash.Add('Department', $($row.Abteilung))
            Write-Host "Updating Department: '$($User.Department)' -> '$($row.Abteilung)'"
        }
        if ($User.Title -ne $($row.Position)) {
            $SetADUserSplatHash.Add('Title', $($row.Position))
            Write-Host "Updating Title: '$($User.Title)' -> '$($row.Position)'"
        }
        if ($User.Company -ne $($row.Gesellschaft)) {
            $SetADUserSplatHash.Add('Company', $($row.Gesellschaft))
            Write-Host "Updating Company: '$($User.Company)' -> '$($row.Gesellschaft)'"
        }
        if ($User.DisplayName -ne $($row.'Name (bevorzugt)')) {
            $SetADUserSplatHash.Add('DisplayName', $($row.'Name (bevorzugt)'))
            Write-Host "Updating DisplayName: '$($User.DisplayName)' -> '$($row.'Name (bevorzugt)')'"
        }
        if ($User.Mobile -ne $($row.'Telefonnummer (geschäftlich)')) {
            if (-not [string]::IsNullOrEmpty($($row.'Telefonnummer (geschäftlich)'))) {
                $SetADUserSplatHash.Add('Mobile', $($row.'Telefonnummer (geschäftlich)'))
                Write-Host "Updating Mobile: '$($User.Mobile)' -> '$($row.'Telefonnummer (geschäftlich)')'"
            } else {
                Write-Host "Skipping Mobile update for user $($User.mail): New value is empty."
            }
        }

        # Lookup Manager using the 'Name (bevorzugt)' field
        $ManagerObject = Get-ADUser -Filter "DisplayName -eq '$($row.'Name (bevorzugt)')'"
        if ($ManagerObject) {
            Write-Host "Manager found: $($ManagerObject.DistinguishedName)"
            $SetADUserSplatHash.Add('Manager', $ManagerObject.DistinguishedName)
        } else {
            Write-Host "Manager not found for user $($row.'E-Mail'): $($row.'Name (bevorzugt)')"
            Write-Host "Attempting to find manager using alternative attributes..."
            
            # Try looking up the manager using other attributes (e.g., mail or SamAccountName)
            $ManagerObject = Get-ADUser -Filter "mail -eq '$($row.'E-Mail')'"
            if ($ManagerObject) {
                Write-Host "Manager found using mail: $($ManagerObject.DistinguishedName)"
                $SetADUserSplatHash.Add('Manager', $ManagerObject.DistinguishedName)
            } else {
                Write-Host "Manager lookup failed. Skipping manager update for user $($row.'E-Mail')."
            }
        }

        # Update AD User
        Set-ADUser @SetADUserSplatHash
    } else {
        Write-Host "User not found: $($row.'E-Mail')"
        $NotFoundList += $row
    }
}

$NotFoundList

# Press Enter to close the PowerShell window
Read-Host "Press Enter to close this window..."

