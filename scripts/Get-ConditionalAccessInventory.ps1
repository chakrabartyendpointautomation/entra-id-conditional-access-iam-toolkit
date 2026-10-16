[CmdletBinding()]
param([switch]$Connect, [string]$OutputDirectory)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
foreach ($moduleName in @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Identity.SignIns')) {
    if (-not (Get-Module -ListAvailable -Name $moduleName)) { throw "Required module '$moduleName' is not installed." }
    Import-Module $moduleName
}
if ($Connect) { Connect-MgGraph -Scopes 'Policy.Read.All' -NoWelcome | Out-Null }
$context = Get-MgContext
if (-not $context) { throw 'No Graph session. Use -Connect or Connect-MgGraph -Scopes Policy.Read.All.' }
if (@($context.Scopes) -notcontains 'Policy.Read.All') { throw 'Current Graph session lacks delegated Policy.Read.All.' }
function Get-CollectionCount {
    param($Value)
    if ($null -eq $Value) { return 0 }
    return @($Value).Count
}
# Read-only Graph v1.0 request. No policy write or simulation endpoint is called.
$policies = @(Get-MgIdentityConditionalAccessPolicy -All)
$rows = foreach ($policy in $policies) {
    $conditions = $policy.Conditions; $users = $conditions.Users; $apps = $conditions.Applications
    $locations = $conditions.Locations; $platforms = $conditions.Platforms; $grant = $policy.GrantControls
    [pscustomobject]@{
        DisplayName = $policy.DisplayName
        State = $policy.State
        CreatedDateTimeUtc = if ($policy.CreatedDateTime) { $policy.CreatedDateTime.ToUniversalTime().ToString('o') } else { $null }
        ModifiedDateTimeUtc = if ($policy.ModifiedDateTime) { $policy.ModifiedDateTime.ToUniversalTime().ToString('o') } else { $null }
        IncludedUserTargetCount = Get-CollectionCount $users.IncludeUsers
        ExcludedUserTargetCount = Get-CollectionCount $users.ExcludeUsers
        IncludedGroupTargetCount = Get-CollectionCount $users.IncludeGroups
        ExcludedGroupTargetCount = Get-CollectionCount $users.ExcludeGroups
        IncludedRoleTargetCount = Get-CollectionCount $users.IncludeRoles
        ExcludedRoleTargetCount = Get-CollectionCount $users.ExcludeRoles
        IncludesAllUsers = @($users.IncludeUsers) -contains 'All'
        IncludesAllApplications = @($apps.IncludeApplications) -contains 'All'
        IncludedApplicationCount = Get-CollectionCount $apps.IncludeApplications
        ExcludedApplicationCount = Get-CollectionCount $apps.ExcludeApplications
        IncludedLocationCount = Get-CollectionCount $locations.IncludeLocations
        ExcludedLocationCount = Get-CollectionCount $locations.ExcludeLocations
        ClientAppTypes = @($conditions.ClientAppTypes) -join ';'
        IncludedPlatformCount = Get-CollectionCount $platforms.IncludePlatforms
        ExcludedPlatformCount = Get-CollectionCount $platforms.ExcludePlatforms
        SignInRiskLevels = @($conditions.SignInRiskLevels) -join ';'
        UserRiskLevels = @($conditions.UserRiskLevels) -join ';'
        GrantControls = @($grant.BuiltInControls) -join ';'
        GrantOperator = $grant.Operator
        SessionControlsPresent = [bool]$policy.SessionControls
    }
}
$rows = @($rows)
if (-not $OutputDirectory) { $rows; return }
$fullOutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($fullOutputDirectory) | Out-Null
$stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
$jsonPath = Join-Path $fullOutputDirectory "conditional-access-inventory-$stamp.json"
$csvPath = Join-Path $fullOutputDirectory "conditional-access-inventory-$stamp.csv"
if ((Test-Path -LiteralPath $jsonPath) -or (Test-Path -LiteralPath $csvPath)) { throw 'Output exists; select another directory and retry.' }
$report = [pscustomobject]@{ GeneratedAtUtc = [DateTime]::UtcNow.ToString('o'); PolicyCount = $rows.Count; Policies = $rows }
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding utf8NoBOM
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding utf8NoBOM
Write-Output $rows
Write-Information "Wrote minimized policy inventory to '$fullOutputDirectory'. Treat output as internal security data." -InformationAction Continue
