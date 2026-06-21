#requires -Version 5.1
<# Created by Dewald Pretorius. This helper does not change Defender protection settings. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','StartHealthServices','ResetPortalCache','FlushDns')][string]$Action='Diagnose',[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Defender_App_Portal_Repair'))
$ErrorActionPreference='Stop';$services=@('WinDefend','SecurityHealthService');$cachePath="$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format yyyyMMdd_HHmmss;$log=Join-Path $OutputPath "Repair_$stamp.log";function Log($m){$l='{0:u} {1}'-f(Get-Date),$m;Write-Host $l;Add-Content $log $l}
[ordered]@{Action=$Action;Services=@($services|ForEach-Object{Get-Service $_ -ErrorAction SilentlyContinue|Select-Object Name,Status,StartType});Portal443=(Test-NetConnection 'security.microsoft.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue);CacheExists=(Test-Path $cachePath)}|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "PreRepair_$stamp.json")
if($Action -eq 'Diagnose'){Log '[COMPLETE] Snapshot saved.';exit 0}
try{if($Action -eq 'StartHealthServices' -and $PSCmdlet.ShouldProcess(($services -join ', '),'Start stopped services')){foreach($name in $services){$svc=Get-Service $name -ErrorAction SilentlyContinue;if($svc -and $svc.Status -eq 'Stopped'){Start-Service $name}}}
elseif($Action -eq 'ResetPortalCache' -and $PSCmdlet.ShouldProcess($cachePath,'Back up and reset Edge portal cache')){if(Get-Process msedge -ErrorAction SilentlyContinue){throw 'Close Edge before resetting its cache.'};if(Test-Path $cachePath){$backup="$cachePath.backup-$stamp";Move-Item $cachePath $backup -Force;New-Item -ItemType Directory $cachePath -Force|Out-Null;Log "[BACKUP] $backup"}}
elseif($Action -eq 'FlushDns' -and $PSCmdlet.ShouldProcess('Windows DNS client cache','Clear')){Clear-DnsClientCache}}catch{Log "[FAILED] $($_.Exception.Message)";exit 5};Log '[COMPLETE] Repair completed without changing protection configuration.';exit 0
