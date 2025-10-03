# Force Uninstall DirectOutput64 Script
# This script attempts multiple methods to remove stubborn DirectOutput64 installations

Write-Host "DirectOutput64 Force Uninstall Script" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

# Method 1: Try normal MSI uninstall for each product
$productCodes = @(
    "{59579A40-5233-4213-AA29-0F0A3219EDEB}",
    "{3BC4FE4C-C16F-4AC5-8C4D-4F0B4F1B2A9B}",
    "{DEB0B99F-1B17-46AC-9C2F-D7E362F3F98A}"
)

foreach ($code in $productCodes) {
    Write-Host "Attempting to uninstall product: $code" -ForegroundColor Cyan
    
    # Try quiet uninstall
    $result = Start-Process "msiexec.exe" -ArgumentList "/x $code /qn" -Wait -PassThru
    Write-Host "MSI uninstall result code: $($result.ExitCode)" -ForegroundColor $(if($result.ExitCode -eq 0) {"Green"} else {"Red"})
    
    # Try forced uninstall
    if ($result.ExitCode -ne 0) {
        Write-Host "Trying forced uninstall..." -ForegroundColor Yellow
        $result2 = Start-Process "msiexec.exe" -ArgumentList "/x $code /qn /forcerestart" -Wait -PassThru
        Write-Host "Forced uninstall result code: $($result2.ExitCode)" -ForegroundColor $(if($result2.ExitCode -eq 0) {"Green"} else {"Red"})
    }
}

# Method 2: Remove registry entries
Write-Host "`nRemoving registry entries..." -ForegroundColor Cyan

$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
)

foreach ($keyPath in $uninstallKeys) {
    foreach ($code in $productCodes) {
        $fullPath = $keyPath + $code
        if (Test-Path $fullPath) {
            try {
                Remove-Item $fullPath -Recurse -Force
                Write-Host "Removed registry key: $fullPath" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove registry key: $fullPath - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Method 3: Clean up Windows Installer cache
Write-Host "`nCleaning Windows Installer cache..." -ForegroundColor Cyan

foreach ($code in $productCodes) {
    $cachePattern = $code.Replace("{", "").Replace("}", "").Replace("-", "")
    $cachePath = "$env:WINDIR\Installer\$cachePattern.msi"
    
    if (Test-Path $cachePath) {
        try {
            Remove-Item $cachePath -Force
            Write-Host "Removed MSI cache file: $cachePath" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove MSI cache file: $cachePath - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Method 4: Remove from Windows Components Store
Write-Host "`nChecking Windows Components Store..." -ForegroundColor Cyan

$componentStore = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\"
foreach ($code in $productCodes) {
    $transformedCode = $code.Replace("{", "").Replace("}", "").Replace("-", "")
    # Transform GUID for registry format
    $registryCode = $transformedCode.Substring(6,2) + $transformedCode.Substring(4,2) + $transformedCode.Substring(2,2) + $transformedCode.Substring(0,2) + 
                   $transformedCode.Substring(10,2) + $transformedCode.Substring(8,2) + $transformedCode.Substring(14,2) + $transformedCode.Substring(12,2) +
                   $transformedCode.Substring(16,16)
    
    $componentPath = $componentStore + $registryCode
    if (Test-Path $componentPath) {
        try {
            Remove-Item $componentPath -Recurse -Force
            Write-Host "Removed component store entry: $componentPath" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to remove component store entry: $componentPath - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`nForce uninstall complete. Please reboot and check Programs and Features." -ForegroundColor Yellow