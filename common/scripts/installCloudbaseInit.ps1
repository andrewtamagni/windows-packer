# Download the latest Cloudbase-ini MSI
try {
    $url = 'https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi'
    $msiPath = 'C:\Windows\Temp\CloudbaseInitSetup_Stable_x64.msi'
    Invoke-WebRequest -Uri $url -OutFile $msiPath -ErrorAction Stop
    Write-Host "Downloaded Cloudbase-Init."
} 
catch {
    Write-Error "Download failed: $_"
    exit 1
}

# Install Cloudbase-init
try {
    Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /qn RUNSYSPREP=0 RUNAS_SYSTEM=1 USERNAME=Administrator USERGROUPS=Administrators" -Wait -NoNewWindow
    Write-Host "Installed Cloudbase-Init."
}
catch {
    Write-Error "Installation failed: $_"
    exit 1
}

# Append these lines to cloudbase-init.conf if not present
$conf = 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf'
$linesToAdd = @(
    'first_logon_behaviour=no',
    'metadata_services=cloudbaseinit.metadata.services.ovfservice.OvfService',
    'plugins=cloudbaseinit.plugins.windows.createuser.CreateUserPlugin,cloudbaseinit.plugins.windows.setuserpassword.SetUserPasswordPlugin,cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin,cloudbaseinit.plugins.common.userdata.UserDataPlugin,cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin'
)
try {
    $existingConf = Get-Content $conf -ErrorAction Stop

    foreach ($line in $linesToAdd) {
        if (-not ($existingConf -match [regex]::Escape($line))) {
            Add-Content -Path $conf -Value $line
            Write-Host "Added to cloudbase-init.conf: $line"
        }
        else {
            Write-Host "Already exists in cloudbase-init.conf: $line"
        }
    }
}
catch {
    Write-Error "Failed to update cloudbase-init.conf: $_"
    exit 1
}

# Replace metadata_services line in cloudbase-init-unattend.conf
$uconf = 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf'
$newLine = 'metadata_services=cloudbaseinit.metadata.services.ovfservice.OvfService'
try {
    $updated = Get-Content $uconf | ForEach-Object {
        if ($_ -match '^metadata_services=') {$newLine} else {$_}
    }

    # If metadata_services was not found, add it
    if ($updated -notmatch '^metadata_services=') {
        $updated += $newLine
    }

    $updated | Set-Content $uconf -Force
    Write-Host "Replaced or added metadata_services in cloudbase-init-unattend.conf"
}
catch {
    Write-Error "Failed to update cloudbase-init-unattend.conf: $_"
    exit 1
}