# reset-git-credentials.ps1
# Clears the cached Azure DevOps credentials from Windows Credential Manager.
# Run this before testing the onboarding workflow from scratch.

Write-Host "Clearing Azure DevOps credentials from Windows Credential Manager..."

$targets = @(
    "git:https://dev.azure.com",
    "git:https://ameliodev@dev.azure.com"
)

$removed = 0
foreach ($target in $targets) {
    try {
        $result = cmdkey /delete:$target 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Removed: $target"
            $removed++
        }
    } catch {
        # Entry did not exist — skip silently
    }
}

# Also remove any entry matching dev.azure.com via generic search
$allCreds = cmdkey /list 2>&1 | Select-String "dev.azure.com"
foreach ($line in $allCreds) {
    $target = ($line -replace ".*Target:\s*", "").Trim()
    if ($target) {
        cmdkey /delete:$target 2>&1 | Out-Null
        Write-Host "  Removed: $target"
        $removed++
    }
}

if ($removed -eq 0) {
    Write-Host "No Azure DevOps credentials found in Credential Manager."
} else {
    Write-Host "Done. $removed credential(s) removed."
}

Write-Host "The next 'git clone' from dev.azure.com will prompt for credentials."
