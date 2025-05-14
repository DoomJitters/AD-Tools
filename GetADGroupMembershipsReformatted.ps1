# Import Active Directory module
Import-Module ActiveDirectory

# Output path
$outputPath = "$env:USERPROFILE\Desktop\AD_Users_and_Their_Groups.csv"

# Create a hashtable to map users to groups
$userGroupMap = @{}

# Get all AD groups
$groups = Get-ADGroup -Filter * -Properties Members

foreach ($group in $groups) {
    $groupName = $group.Name

    try {
        $members = Get-ADGroupMember -Identity $group -Recursive -ErrorAction Stop
        foreach ($member in $members) {
            if ($member.objectClass -eq 'user') {
                if (-not $userGroupMap.ContainsKey($member.SamAccountName)) {
                    $userGroupMap[$member.SamAccountName] = @{
                        DisplayName = $member.Name
                        SamAccountName = $member.SamAccountName
                        ObjectType = $member.ObjectClass
                        Groups = @()
                    }
                }
                $userGroupMap[$member.SamAccountName].Groups += $groupName
            }
        }
    } catch {
        Write-Warning "Unable to retrieve members for group: $groupName"
    }
}

# Format for export
$results = foreach ($entry in $userGroupMap.Values) {
    [PSCustomObject]@{
        DisplayName       = $entry.DisplayName
        SamAccountName    = $entry.SamAccountName
        ObjectType        = $entry.ObjectType
        Groups            = ($entry.Groups | Sort-Object -Unique) -join ", "
    }
}

# Export to CSV
$results | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete. File saved to: $outputPath"
