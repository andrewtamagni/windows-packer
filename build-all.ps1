$tDirs = "Win11Pro24H2", "WinServ2022Stan", "WinServ2025Stan"
$jobs = @()

# Set variables and start jobs for all builds.
foreach ($dir in $tDirs) {
    $job = Start-Job -Name $dir -ScriptBlock {
        param ($dirPath)
        $ErrorActionPreference = "Stop"
        Write-Host "`n[$dirPath] Starting build..."
        Set-Location $dirPath
        $varsFile = "packer.auto.pkrvars.hcl"
        if (Test-Path $varsFile) {
            Remove-Item $varsFile -Force
            Write-Host "[$dirPath] Removed existing $varsFile"
        }

        # Generate vars file
        ..\env-to-vars.ps1

        # Load password from .env
        $envFile = "..\.env"
        if (-not (Test-Path $envFile)) {
            throw "[$dirPath] .env file not found!"
        }
        $winadmin_password = ""
        $lines = Get-Content $envFile
        foreach ($line in $lines) {
            if ($line -match '^\s*winadmin_password\s*=\s*(.+)\s*$') {
                $winadmin_password = $matches[1].Trim()
                break
            }
        }
        if (-not $winadmin_password) {
            throw "[$dirPath] winadmin_password not found in .env file!"
        }

        # Render Autounattend.xml
        $templatePath = Join-Path $dirPath "autounattend.xml.tpl"
        $outputPath = Join-Path $dirPath "Autounattend.xml"

        if (-not (Test-Path $templatePath)) {
            throw "[$dirPath] Missing autounattend.xml.tpl file!"
        }
        $templateContent = Get-Content $templatePath -Raw
        $rendered = $templateContent -replace '\$\{winadmin_password\}', $winadmin_password
        $rendered | Set-Content -Path $outputPath -Encoding UTF8
        Write-Host "[$dirPath] Rendered Autounattend.xml"

        # Run packer
        Write-Host "[$dirPath] Starting packer build..."
        packer init .
        packer build -var-file="packer.auto.pkrvars.hcl" "$($dirPath | Split-Path -Leaf).pkr.hcl"

    } -ArgumentList (Join-Path $PSScriptRoot $dir)

    $jobs += $job
}

# Wait and stream output
foreach ($job in $jobs) {
    Write-Host "`n==== Output from $($job.Name) ====" -ForegroundColor Cyan
    Receive-Job -Job $job -Wait -AutoRemoveJob
}