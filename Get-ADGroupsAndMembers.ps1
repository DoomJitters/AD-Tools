# This script assumes it is being run directly on a Domain Controller.

# Import the Active Directory module (should already be available on DC)
Import-Module ActiveDirectory

# Output CSV path (can be changed)
$outputPath = "$env:USERPROFILE\Desktop\AD_Groups_and_Members.csv"

# Initialize an array to hold the results
$results = @()

# Retrieve all groups in Active Directory
$groups = Get-ADGroup -Filter * -Properties Members

foreach ($group in $groups) {
    $groupName = $group.Name

    # Try to get group members
    try {
        $members = Get-ADGroupMember -Identity $group -Recursive -ErrorAction Stop
        foreach ($member in $members) {
            $results += [PSCustomObject]@{
                GroupName            = $groupName
                MemberName           = $member.Name
                MemberSAMAccountName = $member.SamAccountName
                MemberType           = $member.ObjectClass
            }
        }
    } catch {
        # Group has no members or there's an access issue
        $results += [PSCustomObject]@{
            GroupName            = $groupName
            MemberName           = "[None or Unreadable]"
            MemberSAMAccountName = ""
            MemberType           = ""
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete. File saved to: $outputPath"
