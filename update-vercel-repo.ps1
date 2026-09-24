# Copy Vercel deployment files to the GitHub clone created by update-existing-repo.ps1.
param(
    [string]$Destination = (Join-Path (Split-Path -Parent $PSScriptRoot) 'BSc-IT-AI-Guidance-System-GitHub')
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath (Join-Path $Destination '.git'))) {
    throw "GitHub clone not found at: $Destination. Run update-existing-repo.ps1 first."
}

foreach ($name in @('app.py', 'README.md', 'public', 'scripts')) {
    $from = Join-Path $PSScriptRoot $name
    if (-not (Test-Path -LiteralPath $from)) { throw "Missing deployment file: $from" }
    $to = Join-Path $Destination $name
    if (Test-Path -LiteralPath $from -PathType Container) {
        if (-not (Test-Path -LiteralPath $to)) {
            New-Item -ItemType Directory -Path $to | Out-Null
        }
        Get-ChildItem -LiteralPath $from -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $to -Recurse -Force
        }
    } else {
        Copy-Item -LiteralPath $from -Destination $to -Force
    }
}

& git -C $Destination add -- app.py README.md public scripts
if ($LASTEXITCODE -ne 0) { throw 'Could not stage the deployment changes.' }

Write-Host "`nVercel files staged in: $Destination"
& git -C $Destination status --short
Write-Host "`nReview the changes, then run:"
Write-Host "git -C `"$Destination`" commit -m `"Prepare Flask app for Vercel`""
Write-Host "git -C `"$Destination`" push origin HEAD"
