#Import the CSV file

$csvData = Import-Csv -Path 'path/file.csv'

#Loop through each row in the CSV and update the attribute
foreach ($row in $csvData){
	$acct = $row.Vorname  #store the Vorname for error reporting
	
	$props = @{}

    # Iterate over each property in the row and add it to $props
    foreach ($property in $row.PSObject.Properties) {
        $props[$property.Name] = $property.Value
    }

    try {
        Get-ADUser -Identity $row.SamAccountName -Properties * -ErrorAction Stop | 
            Set-ADUser @props -WhatIf -ErrorAction Stop
    }
    catch {
        Write-Host "User '$acct' not found or failed to update:"
        Write-Host $_
    }
}

# Import the CSV file
$csvData = Import-Csv -Path 'C:\Path\to\your\file.csv'

# Loop through each row in the CSV
foreach ($row in $csvData) {
    # Retrieve user information from the CSV
    $firstName = $row.'First name (legal)'
    $lastName = $row.'Last name (legal)'
    $gender = $row.'Gender'
    $email = $row.'Email'
    $office = $row.'Office'
    $department = $row.'Department'
    $position = $row.'Position'
    $legalEntity = $row.'Legal Entity'
    $team = $row.'Team'
    $status = $row.'Status'
    $employmentType = $row.'Employment type'
	$hireDate = $row.'Hire date'
	$contractEnds = $row.'Contract ends'
	$costCenter = $row.'Cost center'
	$supervisor = $row.'Supervisor'
	$lengthofProbation = $row.'Length of probation'
	$weeklyHours = $row.'Weekly hours'
	$probationPeriodEnd = $row.'Probation period end'
	$terminationDate = $row.'Termination date'
	$fte = $row.'FTE'
	$employeeRoles = $row.'Employee roles'
	$id = $row.'ID'
	$namepref = $row.'Name (preferred)'
	$telefon = $row.'Telefonnummer (geschäftlich)'
	
    # Construct the SamAccountName from first name and last name
    $samAccountName = "$firstName $lastName"

    # Query Active Directory to retrieve the user object
    $user = Get-ADUser -Filter {SamAccountName -eq $samAccountName} -Properties EmailAddress, Office, Department

# Compare user attributes and update AD if necessary
if ($user) {
    if ($user.Email -ne $email) {
        Set-ADUser -Identity $samAccountName -EmailAddress $email -WhatIf
    }
    if ($user.Office -ne $office) {
        Set-ADUser -Identity $samAccountName -Office $office -WhatIf
    }
    if ($user.Department -ne $department) {
        Set-ADUser -Identity $samAccountName -Department $department -WhatIf
    }
    if ($user.Gender -ne $gender) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'gender' = $gender } -WhatIf
    }
    if ($user.Position -ne $position) {
        Set-ADUser -Identity $samAccountName -Title $position -WhatIf
    }
    if ($user.'Legal Entity' -ne $legalEntity) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Legal Entity' = $legalEntity } -WhatIf
    }
    if ($user.Team -ne $team) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Team' = $team } -WhatIf
    }
    if ($user.Status -ne $status) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Status' = $status } -WhatIf
    }
    if ($user.'Employment type' -ne $employmentType) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Employment type' = $employmentType } -WhatIf
    }
    if ($user.'Hire date' -ne $hireDate) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Hire date' = $hireDate } -WhatIf
    }
    if ($user.'Contract ends' -ne $contractEnds) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Contract ends' = $contractEnds } -WhatIf
    }
    if ($user.'Cost center' -ne $costCenter) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Cost center' = $costCenter } -WhatIf
    }
    if ($user.Supervisor -ne $supervisor) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Supervisor' = $supervisor } -WhatIf
    }
    if ($user.'Length of probation' -ne $lengthofProbation) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Length of probation' = $lengthofProbation } -WhatIf
    }
    if ($user.'Weekly hours' -ne $weeklyHours) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Weekly hours' = $weeklyHours } -WhatIf
    }
    if ($user.'Probation period end' -ne $probationPeriodEnd) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Probation period end' = $probationPeriodEnd } -WhatIf
    }
    if ($user.'Termination date' -ne $terminationDate) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Termination date' = $terminationDate } -WhatIf
    }
    if ($user.FTE -ne $fte) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'FTE' = $fte } -WhatIf
    }
    if ($user.'Employee roles' -ne $employeeRoles) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Employee roles' = $employeeRoles } -WhatIf
    }
    if ($user.ID -ne $id) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'ID' = $id } -WhatIf
    }
    if ($user.'Name (preferred)' -ne $namepref) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Name (preferred)' = $namepref } -WhatIf
    }
    if ($user.'Telefonnummer (geschäftlich)' -ne $telefon) {
        Set-ADUser -Identity $samAccountName -Replace @{ 'Telefonnummer (geschäftlich)' = $telefon } -WhatIf
    }
}
    else {
        Write-Host "User with SamAccountName '$samAccountName' not found in Active Directory."
    }
}
