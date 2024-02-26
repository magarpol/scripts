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