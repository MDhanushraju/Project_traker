# Install SonarLint extension in Cursor
$extId = "sonarsource.sonarlint-vscode"

# Try cursor first, then code
$cli = $null
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    $cli = "cursor"
} elseif (Get-Command code -ErrorAction SilentlyContinue) {
    $cli = "code"
} else {
    # Try common Cursor install path on Windows
    $cursorPath = "$env:LOCALAPPDATA\Programs\cursor\bin\cursor.cmd"
    if (Test-Path $cursorPath) {
        & $cursorPath --install-extension $extId
        exit $LASTEXITCODE
    }
    Write-Host "Cursor/code CLI not found. Install manually:" -ForegroundColor Yellow
    Write-Host "1. Open Extensions (Ctrl+Shift+X)" -ForegroundColor Cyan
    Write-Host "2. Search: sonarsource.sonarlint-vscode" -ForegroundColor Cyan
    Write-Host "3. Click Install" -ForegroundColor Cyan
    exit 1
}

Write-Host "Installing $extId via $cli..." -ForegroundColor Cyan
& $cli --install-extension $extId
if ($LASTEXITCODE -eq 0) {
    Write-Host "Done! Reload Cursor if the extension doesn't appear." -ForegroundColor Green
} else {
    Write-Host "Install failed. Try manually: Extensions -> search 'sonarsource.sonarlint-vscode'" -ForegroundColor Yellow
}
