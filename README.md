# Entra ID Conditional Access & IAM Security Toolkit

A defensive, read-only starter toolkit for reviewing Microsoft Entra Conditional Access policy inventory and structuring IAM reviews. It uses Microsoft Graph PowerShell delegated read access. It does not create, update, enable, disable, simulate, or delete tenant objects.

> **Portfolio sample:** Synthetic examples and review guidance only. This is not a tenant assessment, security certification, production deployment, or claim of verified control effectiveness. Validate policy behavior in the target tenant and against current Microsoft guidance.

## Scope and project boundaries

- Collect Conditional Access policy inventory using Microsoft Graph v1.0.
- Summarize policy state, timestamps, target counts, and selected condition/grant-control summaries.
- Exclude policy IDs and user, group, app, location, and device identifiers from the exported summary.
- Provide IAM review prompts for privileged roles, authentication, application identities, and access reviews. The script does not query those resources.

This complements [Endpoint Management Automation](https://github.com/chakrabartyendpointautomation/endpoint-management-automation), which already reports Intune/Entra device inventory and endpoint health. This repository focuses on identity policy inventory and review rather than duplicating device-health collection or remediation.

## CV alignment

The portfolio context supplied for this work describes experience with Intune, Jamf Pro, Entra ID, Conditional Access, MFA/SSO, PowerShell and Graph automation, multi-tenant MDM, and hybrid IAM/PKI/MDM. This repo translates those subject areas into a synthetic demonstration; it does not claim this sample code was used in an employer or customer tenant.

## Repository contents

- [Read-only collector](scripts/Get-ConditionalAccessInventory.ps1)
- [Prerequisites, least-privilege notes, review checklists, synthetic output, and validation plan](REVIEW-GUIDE.md)

## Prerequisites

- PowerShell 7.2 or later.
- Microsoft.Graph.Authentication and Microsoft.Graph.Identity.SignIns PowerShell modules.
- Work or school account with delegated Policy.Read.All consent and an Entra role permitted to read Conditional Access policy objects. Microsoft identifies Policy.Read.All as the least-privileged permission for listing these policies; tenant role requirements also apply.
- Access-controlled output folder if exporting reports.

Install modules for the current user:

    Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
    Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser

## Quick start

Review the script before use. The script connects interactively only when -Connect is supplied; otherwise it requires an existing Graph session with Policy.Read.All.

    # Interactive delegated sign-in; requests only the read scope used by this example.
    ./scripts/Get-ConditionalAccessInventory.ps1 -Connect -OutputDirectory ./out

    # Or reuse an existing session:
    Connect-MgGraph -Scopes Policy.Read.All
    ./scripts/Get-ConditionalAccessInventory.ps1 -OutputDirectory ./out

The script uses Get-MgIdentityConditionalAccessPolicy -All. With no output directory it returns minimized objects to the pipeline and writes no files. When an output directory is provided, it creates timestamped JSON and CSV files and refuses same-name collisions. It does not disconnect an existing Graph session.

## Output and safe handling

The summary contains policy display name, state, timestamps, condition target counts, client-app and risk condition values, grant-control names/operator, and a session-control presence flag. It omits identifiers for the policy and underlying users, groups, applications, locations, and devices. Display names and aggregate counts can still expose sensitive security posture; treat real reports as internal data, store them in an approved location, and never commit tenant output here.

No tokens, secrets, certificates, private keys, sign-in logs, or user authentication-method data appear in the repository. Collection is read-only. A summary does not establish whether a policy is correct or enforced and does not evaluate sign-in outcomes. Any policy change must be separately reviewed, approved, piloted, and verified with a recovery plan.

## Review workflow

1. Agree scope, authorization, evidence, retention, owners, and assessment window.
2. Collect inventory in an approved lab or read-only assessment context.
3. Review policy targeting, exclusions, emergency access, MFA/authentication strength, grant/session controls, overlapping policies, and rollout state.
4. Correlate with approved sign-in and IAM evidence outside this script; record confidence and evidence references.
5. Agree an owner and remediation plan. Use report-only/staged rollout, change control, and a recovery path before enforcement changes.
6. Verify outcomes and document closure.

The detailed [review guide](REVIEW-GUIDE.md) includes data-handling guidance, Conditional Access and adjacent IAM checklists, synthetic output, and validation steps.

## Validation status

No PowerShell parser check, module install, Graph sign-in, test-tenant request, or live-tenant validation was performed while preparing this repository. Validation instructions are in the [review guide](REVIEW-GUIDE.md); they are a plan, not completed test results.

## Microsoft references

- [List Conditional Access policies — Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/conditionalaccessroot-list-policies?view=graph-rest-1.0)
- [Get-MgIdentityConditionalAccessPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.identity.signins/get-mgidentityconditionalaccesspolicy?view=graph-powershell-1.0)
- [Conditional Access policy resource type](https://learn.microsoft.com/graph/api/resources/conditionalaccesspolicy?view=graph-rest-1.0)
- [Conditional Access overview](https://learn.microsoft.com/entra/identity/conditional-access/overview)
