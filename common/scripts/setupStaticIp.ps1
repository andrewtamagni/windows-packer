<# 
Packer Bootstrap Script (setupStaticIp.ps1)
===========================================

Purpose:
- Configure static IPv4 + DNS on the primary NIC
- Ensure network profile is Private (required for WinRM rules)
- Make WinRM reliably available for Packer (even across NIC/driver changes)
- Download & install VMware Tools (best-effort, with retries)
- Add a startup self-heal task that reasserts WinRM until Packer connects
- Log everything to both a transcript and a summary log (also echoed to console)

Usage (Autounattend RunSynchronous in specialize):
  powershell.exe -ExecutionPolicy Bypass -File a:\setupStaticIp.ps1 `
    -IPAddress xx.xx.xx.xx -PrefixLength 24 -Gateway xx.xx.xx.xx `
    -DnsServers "xx.xx.xx.xx,xx.xx.xx.xx"
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$true)]
  [ValidatePattern('^\d{1,3}(\.\d{1,3}){3}$')]
  [string]$IPAddress,

  [Parameter(Mandatory=$true)]
  [ValidateRange(1,32)]
  [int]$PrefixLength,

  [Parameter(Mandatory=$true)]
  [ValidatePattern('^\d{1,3}(\.\d{1,3}){3}$')]
  [string]$Gateway,

  [Parameter(Mandatory=$true)]
  [ValidateNotNullOrEmpty()]
  [object]$DnsServers
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

# Normalize DNS input (support comma string or array)
if ($DnsServers -is [string]) {
  $DnsServers = $DnsServers.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
}

# --- Logging setup ------------------------------------------------------------
$LogDir         = 'C:\Windows\Temp'
$TranscriptPath = Join-Path $LogDir 'Packer_Setup_Transcript.log'
$SummaryLogPath = Join-Path $LogDir 'Packer_Setup_Summary.log'
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Summary {
  param([string]$Message)
  $ts = (Get-Date).ToString('s')
  $line = "$ts  $Message"
  $line | Out-File -FilePath $SummaryLogPath -Append -Encoding UTF8
  Write-Host $line
}

# --- Utilities ----------------------------------------------------------------
function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p  = [Security.Principal.WindowsPrincipal]::new($id)
  return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-WithRetry {
  param(
    [Parameter(Mandatory)][scriptblock]$ScriptBlock,
    [int]$MaxAttempts = 5,
    [int]$DelaySeconds = 5,
    [string]$ActionName = 'operation'
  )
  for ($i=1; $i -le $MaxAttempts; $i++) {
    try { return & $ScriptBlock }
    catch {
      if ($i -eq $MaxAttempts) {
        throw "Failed $ActionName after $MaxAttempts attempts. Error: $($_.Exception.Message)"
      }
      Write-Summary ("Retry {0}/{1} for {2}. Error: {3}" -f $i,$MaxAttempts,$ActionName,$_.Exception.Message)
      Start-Sleep -Seconds $DelaySeconds
    }
  }
}

function Get-PrimaryIfIndex {
  # Prefer interface with default route; fallback to lowest-metric connected NIC
  $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -AddressFamily IPv4 -ErrorAction SilentlyContinue |
           Sort-Object -Property RouteMetric, InterfaceMetric |
           Select-Object -First 1
  if ($route) { return $route.InterfaceIndex }

  $fallback = Get-NetIPInterface -AddressFamily IPv4 |
              Where-Object { $_.ConnectionState -eq 'Connected' } |
              Sort-Object -Property InterfaceMetric |
              Select-Object -First 1
  if (-not $fallback) { throw "No connected IPv4 interfaces found." }
  return $fallback.InterfaceIndex
}

# --- Pre-flight ---------------------------------------------------------------
if (-not (Test-Admin)) { throw "Script must run as Administrator/SYSTEM." }
try { Start-Transcript -Path $TranscriptPath -Force | Out-Null } catch {}
Write-Summary "===== Packer bootstrap started ====="
Write-Summary "Params: IP=$IPAddress/$PrefixLength GW=$Gateway DNS=$($DnsServers -join ', ')"

try {
  # --- Networking: pick adapter, apply static IP/DNS --------------------------
  $ifIndex = Get-PrimaryIfIndex
  $adapter = Get-NetAdapter -InterfaceIndex $ifIndex -ErrorAction Stop
  Write-Summary "Adapter selected: Name='$($adapter.Name)' IfIndex=$ifIndex Status=$($adapter.Status)"

  Write-Summary "Removing existing IPv4 addresses on IfIndex=$ifIndex (best-effort)..."
  Get-NetIPAddress -InterfaceIndex $ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    ForEach-Object {
      try {
        Remove-NetIPAddress -InputObject $_ -Confirm:$false -ErrorAction Stop
        Write-Summary "Removed IP $($_.IPAddress)/$($_.PrefixLength)"
      } catch {
        Write-Summary "WARN: Could not remove $($_.IPAddress): $($_.Exception.Message)"
      }
    }
  Start-Sleep -Seconds 2

  Write-Summary "Assigning static IP $IPAddress/$PrefixLength with gateway $Gateway..."
  New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -AddressFamily IPv4 -ErrorAction Stop
  Write-Summary "Static IP assigned."

  Write-Summary "Setting DNS servers: $($DnsServers -join ', ')"
  Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ResetServerAddresses -ErrorAction Stop
  Start-Sleep -Seconds 1
  Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses $DnsServers -ErrorAction Stop
  Write-Summary "DNS configured."
  try { ipconfig /flushdns | Out-Null } catch {}

  # After IP/DNS changes, reassert WinRM and firewall (handles brief binding gaps)
  Write-Summary "Reasserting WinRM after IP/DNS change..."
  try {
    Restart-Service winrm -Force -ErrorAction SilentlyContinue
    Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue
    Get-NetFirewallRule -DisplayGroup "Windows Remote Management" | Set-NetFirewallRule -Profile Any -Enabled True
    Start-Sleep -Seconds 3
    Write-Summary "WinRM service restarted and firewall rules ensured."
  } catch { Write-Summary "WARN: Post-IP WinRM reassert failed: $($_.Exception.Message)" }

  # --- Ensure Private profile (for WinRM rules) --------------------------------
  try {
    $netProfile = Get-NetConnectionProfile -InterfaceIndex $ifIndex -ErrorAction Stop
    if ($netProfile.NetworkCategory -ne 'Private') {
      Set-NetConnectionProfile -InterfaceIndex $ifIndex -NetworkCategory Private -ErrorAction Stop
      Write-Summary "Network profile set to Private."
    } else {
      Write-Summary "Network profile already Private."
    }
  } catch { Write-Summary "WARN: Failed to set network profile to Private: $($_.Exception.Message)" }

  # --- Base WinRM configuration ------------------------------------------------
  try {
    sc.exe config winrm start= auto | Out-Null
    Start-Service winrm -ErrorAction SilentlyContinue
    winrm quickconfig -quiet | Out-Null
    winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
    winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Null
    Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue | Out-Null
    Get-NetFirewallRule -DisplayGroup "Windows Remote Management" | Set-NetFirewallRule -Profile Any -Enabled True
    Write-Summary "WinRM configured (HTTP/5985; Basic + AllowUnencrypted) and firewall opened on Any profile."
  } catch { Write-Summary "WARN: WinRM configuration step failed: $($_.Exception.Message)" }

  # --- Self-healing WinRM on startup (until Packer removes it) -----------------
  try {
    $FixerPath = 'C:\Windows\Temp\Ensure-WinRM.ps1'
    @'
$ErrorActionPreference = "Stop"
try {
  sc.exe config winrm start= auto | Out-Null
  Start-Service winrm -ErrorAction SilentlyContinue
  winrm quickconfig -quiet | Out-Null
  winrm set winrm/config/service '@{AllowUnencrypted="true"}' | Out-Null
  winrm set winrm/config/service/auth '@{Basic="true"}' | Out-Null
  Enable-PSRemoting -SkipNetworkProfileCheck -Force | Out-Null
  Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue | Out-Null
  Get-NetFirewallRule -DisplayGroup "Windows Remote Management" | Set-NetFirewallRule -Profile Any -Enabled True
} catch { }
'@ | Set-Content -Path $FixerPath -Encoding UTF8 -Force

    $action    = New-ScheduledTaskAction  -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$FixerPath`""
    $trigger   = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    Register-ScheduledTask -TaskName "Ensure-WinRM-AtStartup" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
    Write-Summary "Registered startup task: Ensure-WinRM-AtStartup."
  } catch {
    Write-Summary "WARN: Could not register Ensure-WinRM-AtStartup task: $($_.Exception.Message)"
  }

  # --- VMware Tools (best-effort, with retries) --------------------------------
  try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
  $DownloadFolder = 'C:\install'
  if (-not (Test-Path $DownloadFolder)) { New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null }
  $baseUrl  = "https://packages.vmware.com/tools/releases/latest/windows/x64/"
  Write-Summary "Locating latest VMware Tools from $baseUrl"

  $vmtoolsFile = Invoke-WithRetry -ActionName "fetch VMware Tools index" -ScriptBlock {
    (Invoke-WebRequest -Uri $baseUrl -UseBasicParsing).Links |
      Where-Object { $_.href -match '^VMware-tools-.*\.exe$' } |
      Select-Object -ExpandProperty href -First 1
  }
  if ($vmtoolsFile) {
    $downloadUrl = "$baseUrl$vmtoolsFile"
    $localPath   = Join-Path $DownloadFolder (Split-Path -Path $vmtoolsFile -Leaf)
    Write-Summary "Downloading VMware Tools -> $localPath"
    Invoke-WithRetry -ActionName "download VMware Tools" -ScriptBlock {
      Invoke-WebRequest -Uri $downloadUrl -OutFile $localPath -UseBasicParsing
    }
    Write-Summary "Installing VMware Tools silently..."
    Invoke-WithRetry -ActionName "install VMware Tools" -ScriptBlock {
      Start-Process -FilePath $localPath -ArgumentList '/S /v"/qn REBOOT=ReallySuppress" /l c:\windows\temp\vmware_tools_install.log' -Wait
    }
    Write-Summary "VMware Tools installation completed."

    # vmxnet3 driver swap can create a new NIC instance → reassert Private + WinRM
    Write-Summary "Reasserting Private profile and WinRM after VMware Tools (nic rebind guard)..."
    try {
      Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' } |
        ForEach-Object { Set-NetConnectionProfile -InterfaceAlias $_.InterfaceAlias -NetworkCategory Private }
      Enable-PSRemoting -SkipNetworkProfileCheck -Force | Out-Null
      Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -ErrorAction SilentlyContinue | Out-Null
      Get-NetFirewallRule -DisplayGroup "Windows Remote Management" | Set-NetFirewallRule -Profile Any -Enabled True
      sc.exe config winrm start= auto | Out-Null
      Start-Service winrm -ErrorAction SilentlyContinue
      Write-Summary "Post-Tools: Private profile & WinRM reasserted."
    } catch {
      Write-Summary "WARN: Post-Tools reassert failed: $($_.Exception.Message)"
    }
  } else {
    Write-Summary "WARN: No VMware Tools link found; skipping Tools installation."
  }

  # --- Reset autologon for Autounattend flow ----------------------------------
  try {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0 -ErrorAction Stop
    Write-Summary "AutoLogonCount reset to 0."
  } catch {
    Write-Summary "WARN: Failed to reset AutoLogonCount: $($_.Exception.Message)"
  }

  Write-Summary "All bootstrap operations completed successfully."
}
catch {
  Write-Summary "ERROR: $($_.Exception.Message)"
  throw
}
finally {
  try { Stop-Transcript | Out-Null } catch {}
  Write-Summary "===== Packer bootstrap ended ====="
}