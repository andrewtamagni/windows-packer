# Convert .env to packer.auto.pkrvars.hcl

$envFile = "..\.env"
$outFile = ".\packer.auto.pkrvars.hcl"
$folderKey = (Split-Path -Leaf (Get-Location)).ToLower()
$desktop = @("win10pro22h2", "win11pro24h2")
$server  = @("winserv2022stan", "winserv2025stan")

if (-Not (Test-Path $envFile)) {
    Write-Error ".env file not found at $envFile"
    exit 1
}

Write-Host "Reading variables from $envFile..."
$lines = Get-Content $envFile | Where-Object { $_ -match "=" -and $_ -notmatch "^\s*#" }

$kvMap = @{}
$output = @{}

# Parse .env file into key/value map
foreach ($line in $lines) {
    $parts = $line -split "=", 2
    $key = $parts[0].Trim().ToLower()
    $val = $parts[1].Trim()
    if ($key -and $val) {
        $kvMap[$key] = $val

        if ($key -eq "winrm_password") {
            $env:winrm_password = $val
            Write-Host "Exported winrm_password to environment"
        }
    }
}

# Set vsphere_template_name
$today = Get-Date -Format "yyyyMMdd"
$vmName = "$($folderKey)-$today"
$output["vsphere_template_name"] = $vmName
Write-Host "Generated vsphere_template_name = $vmName"

# Set os_iso_path
$isoKey = "iso_path_$folderKey"
if ($kvMap.ContainsKey($isoKey)) {
    $output["os_iso_path"] = $kvMap[$isoKey]
    Write-Host "Added os_iso_path = $($kvMap[$isoKey])"
} else {
    Write-Warning "No ISO path found for $isoKey in .env"
}

# Set profile-based defaults
$prefix = if ($desktop -contains $folderKey) {
    "desk_"
} elseif ($server -contains $folderKey) {
    "serv_"
} else {
    Write-Warning "Unknown folder $folderKey — using base values for CPU, memory, disk"
    ""
}

# Resolve cpu_num, mem_size, disk_size
foreach ($var in @("cpu_num", "mem_size", "disk_size")) {
    $preferred = "$prefix$var"
    if ($kvMap.ContainsKey($preferred)) {
        $output[$var] = $kvMap[$preferred]
    } elseif ($kvMap.ContainsKey($var)) {
        $output[$var] = $kvMap[$var]
    } else {
        Write-Warning "Missing value for $var"
    }
}

# Include winadmin_password explicitly
if ($kvMap.ContainsKey("winadmin_password")) {
    $output["winadmin_password"] = $kvMap["winadmin_password"]
}

# Include remaining shared variables (exclude secrets and prefixed keys)
foreach ($key in $kvMap.Keys) {
    if ($key -notlike "iso_path_*" -and
        $key -notlike "desk_*" -and
        $key -notlike "serv_*" -and
        $key -ne "winrm_password" -and
        $key -ne "winadmin_password" -and
        -not $output.ContainsKey($key)) {

        $output[$key] = $kvMap[$key]
    }
}

# Write sorted output
Write-Host "Writing to $outFile..."
$output.GetEnumerator() |
    Sort-Object Name |
    ForEach-Object { "$($_.Key) = `"$($_.Value)`"" } |
    Set-Content $outFile -Encoding UTF8

Write-Host "packer build -var-file=packer.auto.pkrvars.hcl ."