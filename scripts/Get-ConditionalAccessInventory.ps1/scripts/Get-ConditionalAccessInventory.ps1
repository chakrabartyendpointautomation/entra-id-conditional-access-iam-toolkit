[CmdletBinding()]
param(
    [switch]$Connect,
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$requiredModules = @('Microsoft.Graph.Authentication', 'Microsoft.Graph.Identity.SignIns')
foreach ($moduleName in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $moduleName)) {
        throw "Required module '$moduleName' is not installed. See README prerequisites."
    }
}

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.SignIns

if ($Connect) {
    # Delegated interactive sign-in. No credentials are read from files or stored here.
    Connect-MgGraph -Scopes 'Policy.Read.All' -NoWelcome | Out-Null
}

$context = Get-MgContext
if (-not $context) {
    throw 'No Microsoft Graph session. Use -Connect or sign in with Connect-MgGraph -Scopes Policy.Read.All.'
}
if (@($context.Scopes) -notcontains 'Policy.Read.All') {
    throw "The current Graph session lacks Policy.Read.All. Reconnect with the required delegated scope."
}

# Read-only Graph request. No policy write or simulation endpoint is called.
$policies = @(Get-MgIdentityConditionalAccessPolicy -All)
$rows = foreach ($policy in $policies) {
    $conditions = $policy.Conditions
    $users = $conditions.Users
    $apps = $conditions.Applications
    $locations = $conditions.Locations
    $platforms = $conditions.Platforms
    $grant = $policy.GrantControls
    $session = $policy.SessionControls

    [pscustomobject]@{
        DisplayName                 = $policy.DisplayName
        State                       = $policy.State
        CreatedDateTimeUtc          = if ($policy.CreatedDateTime) { $policy.CreatedDateTime.ToUniversalTime().ToString('o') } else { $null }
        ModifiedDateTimeUtc         = if ($policy.ModifiedDateTime) { $policy.ModifiedDateTime.ToUniversalTime().ToString('o') } else { $null }
        IncludedUserTargetCount     = @($users.IncludeUsers).Count
        ExcludedUserTargetCount     = @($users.ExcludeUsers).Count
        IncludedGroupTargetCount    = @($users.IncludeGroups).Count
        ExcludedGroupTargetCount    = @($users.ExcludeGroups).Count
        IncludedRoleTargetCount     = @($users.IncludeRoles).Count
        ExcludedRoleTargetCount     = @($users.ExcludeRoles).Count
        IncludesAllUsers            = @($users.IncludeUsers) -contains 'All'
        IncludesAllApplications     = @($apps.IncludeApplications) -contains 'All'
        IncludedApplicationCount    = @($apps.IncludeApplications).Count
        ExcludedApplicationCount    = @($apps.ExcludeApplications).Count
        IncludedLocationCount       = @($locations.IncludeLocations).Count
        ExcludedLocationCount       = @($locations.ExcludeLocations).Count
        ClientAppTypes              = @($conditions.ClientAppTypes) -join ';'
        IncludedPlatformCount       = @($platforms.IncludePlatforms).Count
        ExcludedPlatformCount       = @($platforms.ExcludePlatforms).Count
        SignInRiskLevels            = @($conditions.SignInRiskLevels) -join ';'
        UserRiskLevels              = @($conditions.UserRiskLevels) -join ';'
        GrantControls               = @($grant.BuiltInControls) -join ';'
        GrantOperator               = $grant.Operator
        SessionControlsPresent      = [bool]$session
    }
}

$rows = @($rows)
if (-not $OutputDirectory) {
    $rows
    return
}

$fullOutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($fullOutputDirectory) | Out-Null
$stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
$jsonPath = Join-Path $fullOutputDirectory "conditional-access-inventory-$stamp.json"
$csvPath = Join-Path $fullOutputDirectory "conditional-access-inventory-$stamp.csv"
if ((Test-Path -LiteralPath $jsonPath) -or (Test-Path -LiteralPath $csvPath)) {
    throw 'An output file with this timestamp already exists; choose a different output directory and retry.'
}

$report = [pscustomobject]@{
    GeneratedAtUtc = [DateTime]::UtcNow.ToString('o')
    PolicyCount    = $rows.Count
    Policies       = $rows
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding utf8NoBOM
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding utf8NoBOM
Write-Output $rows
Write-Information "Wrote minimized policy inventory to '$fullOutputDirectory'. Review and protect output as internal security data." -InformationAction Continue
