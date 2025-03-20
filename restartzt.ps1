# Check if running with admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an Administrator" -ForegroundColor Red
    exit
}

# Find the ZeroTier service
Write-Host "Looking for ZeroTier service..."
$ztService = Get-Service | Where-Object { $_.Name -like "*zerotier*" }

if ($null -eq $ztService) {
    Write-Host "ZeroTier service not found. Please ensure ZeroTier is installed." -ForegroundColor Red
    exit
}

$serviceName = $ztService.Name
Write-Host "Found ZeroTier service: $serviceName"

# Stop ZeroTier service
Write-Host "Stopping ZeroTier service ($serviceName)..."
try {
    # Increase timeout for stopping the service
    Stop-Service -Name $serviceName -Force -ErrorAction Stop
    $timeout = 10  # Wait up to 10 seconds for the service to stop
    $timer = [Diagnostics.Stopwatch]::StartNew()
    while (($timer.ElapsedMilliseconds -lt ($timeout * 1000)) -and ($ztService.Status -ne "Stopped")) {
        Start-Sleep -Seconds 1
        $ztService.Refresh()
    }
    if ($ztService.Status -ne "Stopped") {
        throw "Service did not stop within $timeout seconds."
    }
} catch {
    Write-Host "Failed to stop service: $_" -ForegroundColor Yellow
    Write-Host "Attempting to kill ZeroTier processes..." -ForegroundColor Yellow
    # Forcefully kill any ZeroTier processes
    Get-Process | Where-Object { $_.ProcessName -like "*zerotier*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Verify service is stopped
$ztService.Refresh()
if ($ztService.Status -ne "Stopped") {
    Write-Host "Service did not stop properly. Please check for errors." -ForegroundColor Red
    exit
}

# Flush routing table using netsh
Write-Host "Flushing routing table..."
try {
    $routeBefore = route print
    netsh interface ip delete destinationcache
    netsh interface ip delete arpcache
    $routeAfter = route print
    if ($routeBefore -ne $routeAfter) {
        Write-Host "Routing table flushed successfully" -ForegroundColor Green
    } else {
        Write-Host "Routing table may not have been flushed properly" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error flushing routing table: $_" -ForegroundColor Red
}

# Restart ZeroTier service
Write-Host "Starting ZeroTier service ($serviceName)..."
try {
    Start-Service -Name $serviceName -ErrorAction Stop
    Start-Sleep -Seconds 3
} catch {
    Write-Host "Failed to start ZeroTier service: $_" -ForegroundColor Red
    exit
}

# Verify service is running
$ztService.Refresh()
if ($ztService.Status -eq "Running") {
    Write-Host "ZeroTier service successfully restarted" -ForegroundColor Green
} else {
    Write-Host "Failed to restart ZeroTier service. Current status: $($ztService.Status)" -ForegroundColor Red
    exit
}

# Restart ZeroTier UI
Write-Host "Attempting to restart ZeroTier UI..."
try {
    # Look for the ZeroTier UI executable (adjust path if needed)
    $ztUIPath = "C:\Program Files (x86)\ZeroTier\One\zerotier_desktop_ui.exe"
    if (Test-Path $ztUIPath) {
        Start-Process -FilePath $ztUIPath -ErrorAction Stop
        Write-Host "ZeroTier UI restarted successfully" -ForegroundColor Green
    } else {
        Write-Host "ZeroTier UI executable not found at $ztUIPath. Please start the UI manually." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Failed to restart ZeroTier UI: $_" -ForegroundColor Red
    Write-Host "Please start the ZeroTier UI manually." -ForegroundColor Yellow
}
