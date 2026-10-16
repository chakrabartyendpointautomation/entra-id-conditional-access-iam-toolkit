# Entra ID Conditional Access & IAM Security Toolkit

A defensive, read-only starter toolkit for reviewing Microsoft Entra Conditional Access policy inventory and structuring IAM reviews. It uses Microsoft Graph PowerShell delegated read access. It does not create, update, enable, disable, or delete tenant objects.

> **Portfolio sample:** Synthetic examples and review guidance only. This is not a tenant assessment, security certification, production deployment, or claim of verified control effectiveness. Validate policy behavior in the target tenant and against current Microsoft guidance.

## Scope

- Collect a minimized inventory of Conditional Access policies from Microsoft Graph.
- Summarize policy state and condition coverage without exporting user, group, application, or location identifiers.
- Provide human review guidance for policy scope, exclusions, emergency access, MFA, device requirements, report-only rollout, and change control.
- Provide IAM review prompts for role assignment, privileged access, authentication strength, service principals, and access reviews. The sample script does not query these resources.

This complements [Endpoint Management Automation](https://github.com/chakrabartyendpointautomation/endpoint-management-automation), which already collects Intune/Entra device inventory and endpoint health reports. This project focuses on identity policy inventory and review; it does not duplicate device-health collection or remediation.

## CV alignment

The portfolio context supplied for this work describes experience with Intune, Jamf Pro, Entra ID, Conditional Access, MFA/SSO, PowerShell and Microsoft Graph automation, multi-tenant MDM, and hybrid IAM/PKI/MDM. This repo translates those subject areas into a synthetic demonstration. It does not claim this sample code was used in an employer or customer tenant.

## Contents

- scripts/Get-ConditionalAccessInventory.ps1 — read-only Graph collection and minimized JSON/CSV export
- docs/security-and-permissions.md — prerequisites, least privilege, data handling, and safe operation
- docs/review-checklist.md — human review checklist
- samples/conditional-access-inventory.sample.json — fictional output shape
- VALIDATION.md — validation steps and verification status

## Prerequisites

- PowerShell 7.2 or later.
- Microsoft Graph PowerShell modules Microsoft.Graph.Authentication and Microsoft.Graph.Identity.SignIns.
- Work or school account with delegated Policy.Read.All consent and an appropriate Entra role to read Conditional Access policies (for example Security Reader, Global Reader, Security Administrator, or Conditional Access Administrator, subject to tenant role design).
- Access-controlled output folder if saving a report.

Install for the current user:

    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
    Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser

## Quick start

Review the script before use. It connects interactively only with -Connect; otherwise it requires an existing Graph session containing Policy.Read.All.

    # Interactive delegated sign-in; requests only the read scope used by this example.
    ./scripts/Get-ConditionalAccessInventory.ps1 -Connect -OutputDirectory ./out

    # Or reuse an existing session:
    Connect-MgGraph -Scopes Policy.Read.All
    ./scripts/Get-ConditionalAccessInventory.ps1 -OutputDirectory ./out

The script uses Microsoft Graph v1.0 cmdlet Get-MgIdentityConditionalAccessPolicy -All. It writes timestamped JSON and flattened CSV only to the specified directory. It contains no Graph write operation. Without an output directory, it returns objects to the pipeline and creates no files.

## Output and privacy

The summary contains policy display name, state, timestamps, and counts/presence flags for selected conditions and grant controls. It omits policy IDs and underlying user, group, app, network-location, and device identifiers. Display names can still expose sensitive naming conventions. Treat real output as internal security data; do not publish it.

No tokens, secrets, certificates, private keys, sign-in logs, user authentication methods, or tenant identifiers appear in the samples. See samples/conditional-access-inventory.sample.json.

## Safe operating model

- Collection is read-only; no create/update/delete/enable/disable/simulation call is included.
- Use delegated access and the narrowest suitable operator role. Avoid application permissions for an interactive review unless separately approved.
- Start in an approved lab or test tenant. Confirm consent and role eligibility before connecting.
- Store reports in an approved location and follow retention rules.
- A summary does not prove enforcement or policy effectiveness and does not evaluate sign-in outcomes.
- Apply recommendations separately through change management, a pilot, and a recovery plan.

## Review workflow

1. Agree on tenant, scope, evidence, retention, reviewers, and assessment window.
2. Collect and minimize policy inventory.
3. Inspect targeting, exclusions, emergency access, grant/session controls, and rollout state with docs/review-checklist.md.
4. Correlate findings with authorized sign-in analysis and organizational context outside this script.
5. Record evidence, confidence, owner, impact, and remediation plan; obtain policy-owner review.
6. Pilot approved changes in report-only or staged assignments where appropriate, with a documented recovery path.
7. Verify outcomes before closing findings.

## Validation status

No PowerShell execution or live-tenant validation was performed while creating this repository. Follow VALIDATION.md in a disposable lab or controlled test tenant before relying on the example.

## Microsoft references

- [List Conditional Access policies (Graph v1.0)](https://learn.microsoft.com/graph/api/conditionalaccessroot-list-policies?view=graph-rest-1.0)
- [Get-MgIdentityConditionalAccessPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.identity.signins/get-mgidentityconditionalaccesspolicy?view=graph-powershell-1.0)
- [Conditional Access policy resource](https://learn.microsoft.com/graph/api/resources/conditionalaccesspolicy?view=graph-rest-1.0)
- [Conditional Access overview](https://learn.microsoft.com/entra/identity/conditional-access/overview)

The next portfolio work is Windows Autopilot & Intune Provisioning Lab. A separate Graph reporting repository would duplicate reporting already in endpoint-management-automation and should be scoped there as an incremental reusable module instead.
