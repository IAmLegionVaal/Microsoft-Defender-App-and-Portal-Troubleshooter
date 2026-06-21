# Microsoft Defender App and Portal Troubleshooter

Created by **Dewald Pretorius**.

`Troubleshooter.ps1` collects Defender application, portal, alert, onboarding, and local-health evidence. `Repair.ps1` adds guarded `Diagnose`, `StartHealthServices`, `ResetPortalCache`, and `FlushDns` actions.

```powershell
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action StartHealthServices -WhatIf
.\Repair.ps1 -Action ResetPortalCache -Confirm
```

The helper records pre-change service and portal state. It starts only stopped health services and does not change Defender protection configuration. Existing Edge cache data is preserved as a timestamped backup. Source-reviewed; not runtime-tested in every Defender deployment.
