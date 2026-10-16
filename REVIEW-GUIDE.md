# Review, Permissions & Validation Guide

## Prerequisites and least privilege

The collector requires PowerShell 7.2+, Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns, delegated Microsoft Graph permission Policy.Read.All, and a work or school account with an Entra role permitted to read Conditional Access policies. Microsoft documents Policy.Read.All as the least-privileged permission for listing policies. Security Reader, Global Reader, Security Administrator, or Conditional Access Administrator may satisfy the role requirement, subject to the tenant's configuration and the operator's intended scope.

Use interactive delegated sign-in for an operator-led review. The script's -Connect switch requests only Policy.Read.All. An administrator may need to grant consent. Do not add Policy.ReadWrite.ConditionalAccess or broader permissions for this read-only workflow. Do not place secrets, certificates, refresh tokens, or tenant data in the repository.

## Safe handling

- Start in an authorized test tenant or approved read-only assessment scope.
- Confirm the operator role, consent, assessment window, data owner, and retention requirements before collecting.
- Inventory output can disclose policy names, state, condition counts, and security posture. Store it in an access-controlled location; never commit real output to a public repository.
- The sample intentionally excludes policy IDs and included/excluded principals, groups, applications, named locations, and device identifiers. It still includes policy display names, which may themselves be sensitive.
- Do not treat a missing or empty field as proof that a control is absent or ineffective. Confirm against the tenant UI and current Graph response shape.
- This tool does not read sign-in logs, authentication methods, role assignments, service-principal credentials, or access-review records. Those require separately authorized review steps.
- No tenant changes are made. Any recommended change needs owner review, a documented change, pilot scope, communications, recovery plan, and post-change verification.

## Conditional Access review checklist

For each policy, record status, owner, intent, last reviewed date, evidence location, confidence, and follow-up owner.

### Scope and targeting

- [ ] Is the policy purpose and affected user population documented?
- [ ] Are included users, groups, roles, applications, platforms, client types, risk levels, and locations intentional and current?
- [ ] Are excluded users/groups/apps minimal, owned, time-bound where appropriate, and periodically reviewed?
- [ ] Are group nesting, dynamic membership, guest/external identities, workload identities, and emergency access considered?
- [ ] Do overlapping policies produce the intended combined result?

### Grant and session controls

- [ ] Are MFA and authentication-strength requirements aligned with the risk and available methods?
- [ ] Are compliant-device, approved-app, terms-of-use, or other grant controls scoped and supportable?
- [ ] Are grant-control combinations and operator (AND/OR) intentional?
- [ ] Are sign-in frequency, persistent browser session, application-enforced restrictions, and other session controls justified?
- [ ] Are legacy authentication and unsupported clients addressed without creating unmanaged lockout risk?

### Operations and resilience

- [ ] Are emergency access accounts protected, monitored, excluded only where needed, and tested under an approved procedure?
- [ ] Are break-glass credentials independently secured and not used for routine administration?
- [ ] Has policy behavior been reviewed using report-only insights or an approved pilot before enforcement?
- [ ] Is there an owner-approved rollback path and a way to reach administrators if access is interrupted?
- [ ] Are changes, exceptions, expiry dates, evidence, and approvals recorded?

## Adjacent IAM review prompts

These are human review prompts; the included script does not collect these data.

- Privileged role assignments: standing versus eligible access, role scope, approvers, duration, periodic review, and emergency access.
- Authentication: MFA registration coverage, authentication strength, method suitability, recovery paths, and user impact. Avoid exporting individual method details into portfolio artifacts.
- Applications and workload identities: owner, business purpose, consent grants, credential age/rotation responsibility, unused identities, and least privilege. Never publish secret values or credential identifiers.
- Access reviews: scope, reviewer independence, decision follow-through, exceptions, and closure evidence.
- Joiner/mover/leaver lifecycle: authoritative source, timely deprovisioning, group/role changes, and orphaned accounts.
- Federation and cross-tenant access: trust scope, inbound/outbound controls, guest lifecycle, and accountable owner.

## Synthetic output example

This fictional sample shows the minimized JSON shape. Names and counts are invented; no real tenant data is represented.

    {
      "GeneratedAtUtc": "2026-01-15T10:30:00.0000000Z",
      "PolicyCount": 1,
      "Policies": [
        {
          "DisplayName": "DEMO - Require MFA for workforce",
          "State": "enabledForReportingButNotEnforced",
          "CreatedDateTimeUtc": "2025-11-01T09:00:00.0000000Z",
          "ModifiedDateTimeUtc": "2026-01-10T12:00:00.0000000Z",
          "IncludedUserTargetCount": 1,
          "ExcludedUserTargetCount": 1,
          "IncludedGroupTargetCount": 0,
          "ExcludedGroupTargetCount": 0,
          "IncludedRoleTargetCount": 0,
          "ExcludedRoleTargetCount": 0,
          "IncludesAllUsers": true,
          "IncludesAllApplications": true,
          "IncludedApplicationCount": 1,
          "ExcludedApplicationCount": 0,
          "IncludedLocationCount": 1,
          "ExcludedLocationCount": 0,
          "ClientAppTypes": "all",
          "IncludedPlatformCount": 0,
          "ExcludedPlatformCount": 0,
          "SignInRiskLevels": "",
          "UserRiskLevels": "",
          "GrantControls": "mfa",
          "GrantOperator": "OR",
          "SessionControlsPresent": false
        }
      ]
    }

The target counts do not identify which principals are included or excluded. A count is not an evaluation of policy correctness.

## Validation instructions and status

**Status: not executed here.** No PowerShell parser check, module installation, Graph sign-in, test-tenant request, or live-tenant validation was performed while preparing this repository. These are steps for a maintainer to run in a disposable lab or approved test tenant:

1. Review the script and verify its only Graph request is Get-MgIdentityConditionalAccessPolicy -All.
2. Parse the script locally with PowerShell: [System.Management.Automation.Language.Parser]::ParseFile(...), and inspect parse errors.
3. Confirm a session without Policy.Read.All exits with the intended error and does not call the policy cmdlet.
4. In an authorized test tenant, connect with delegated Policy.Read.All; run without OutputDirectory and compare summary fields to the tenant's policy inventory.
5. Run with an access-controlled temporary output directory; inspect JSON/CSV to confirm the output contains no policy/principal/group/app/location IDs and no sign-in or authentication-method data.
6. Verify timestamps, zero-policy behavior, and an inaccessible/consent-denied case. Remove test exports afterward.
7. Record PowerShell and Graph module versions, tenant type, date, and results in a validation record without storing tenant identifiers or output files.

These steps are a plan, not completed test results. Do not describe this repository as tested until they have actually been run and recorded.

## Primary references

- [List Conditional Access policies — Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/conditionalaccessroot-list-policies?view=graph-rest-1.0)
- [Get-MgIdentityConditionalAccessPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.identity.signins/get-mgidentityconditionalaccesspolicy?view=graph-powershell-1.0)
- [Conditional Access policy resource](https://learn.microsoft.com/graph/api/resources/conditionalaccesspolicy?view=graph-rest-1.0)
- [Conditional Access overview](https://learn.microsoft.com/entra/identity/conditional-access/overview)
