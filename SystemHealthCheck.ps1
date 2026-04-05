# System Health Check Script - PowerShell Version
# Created by Tobias and Claw for practical testing of self-sufficient automation
# Version: 0.1.0
# Designed to run independently without AI dependencies

# Configuration - easy to modify
$ThresholdCpuWarning = 80
$ThresholdCpuCritical = 95
$ThresholdMemoryWarning = 80
$ThresholdMemoryCritical = 95
$ThresholdDiskWarning = 85
$ThresholdDiskCritical = 95
$LogFile = "H:\OpenClaw\logs\system_health_check.log"
$AlertEmail = ""  # Leave empty for console only, or set email address

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to log file
    try {
        Add-Content -Path $LogFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        # If logging fails, at least show on console
        Write-Host "LOG ERROR: $logEntry" -ForegroundColor DarkRed
    }
    
    # Also output to console with colors
    switch ($Level) {
        "WARN" { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
        "CRIT" { Write-Host "[CRIT] $Message" -ForegroundColor Red }
        "INFO" { Write-Host "[INFO] $Message" -ForegroundColor Green }
        default { Write-Host $Message }
    }
}

# Check CPU usage
function Check-Cpu {
    try {
        $cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
        $cpuUsage = [math]::Round($cpuUsage, 1)
        
        if ($cpuUsage -ge $ThresholdCpuCritical) {
            Write-Log "CPU usage critical: $cpuUsage%" "CRIT"
            return 2
        }
        elseif ($cpuUsage -ge $ThresholdCpuWarning) {
            Write-Log "CPU usage warning: $cpuUsage%" "WARN"
            return 1
        }
        else {
            Write-Log "CPU usage OK: $cpuUsage%" "INFO"
            return 0
        }
    }
    catch {
        Write-Log "Error checking CPU: $_" "WARN"
        return 1
    }
}

# Check memory usage
function Check-Memory {
    try {
        $memInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $memoryUsage = ($memInfo.TotalVisibleMemorySize - $memInfo.FreePhysicalMemory) / $memInfo.TotalVisibleMemorySize * 100
        $memoryUsage = [math]::Round($memoryUsage, 1)
        
        if ($memoryUsage -ge $ThresholdMemoryCritical) {
            Write-Log "Memory usage critical: $memoryUsage%" "CRIT"
            return 2
        }
        elseif ($memoryUsage -ge $ThresholdMemoryWarning) {
            Write-Log "Memory usage warning: $memoryUsage%" "WARN"
            return 1
        }
        else {
            Write-Log "Memory usage OK: $memoryUsage%" "INFO"
            return 0
        }
    }
    catch {
        Write-Log "Error checking memory: $_" "WARN"
        return 1
    }
}

# Check disk usage for C: drive
function Check-Disk {
    try {
        $diskInfo = Get-PSDrive C | Select-Object -Property Used, Free
        $totalSize = $diskInfo.Used + $diskInfo.Free
        $diskUsage = ($diskInfo.Used / $totalSize) * 100
        $diskUsage = [math]::Round($diskUsage, 1)
        
        if ($diskUsage -ge $ThresholdDiskCritical) {
            Write-Log "Disk usage critical: $diskUsage%" "CRIT"
            return 2
        }
        elseif ($diskUsage -ge $ThresholdDiskWarning) {
            Write-Log "Disk usage warning: $diskUsage%" "WARN"
            return 1
        }
        else {
            Write-Log "Disk usage OK: $diskUsage%" "INFO"
            return 0
        }
    }
    catch {
        Write-Log "Error checking disk: $_" "WARN"
        return 1
    }
}

# Check essential services
function Check-Services {
    try {
        $services = @("Spooler", "Winmgmt", "Schedule")  # Print Spooler, WMI, Task Scheduler
        $failed = 0
        
        foreach ($service in $services) {
            $serviceStatus = Get-Service -Name $service -ErrorAction SilentlyContinue
            if (-not $serviceStatus -or $serviceStatus.Status -ne 'Running') {
                Write-Log "Service $service is not running" "WARN"
                $failed++
            }
        }
        
        if ($failed -gt 0) {
            Write-Log "$failed service(s) not running" "WARN"
            return 1
        }
        else {
            Write-Log "All essential services running" "INFO"
            return 0
        }
    }
    catch {
        Write-Log "Error checking services: $_" "WARN"
        return 1
    }
}

# Main execution
function Main {
    Write-Log "Starting system health check" "INFO"
    
    # Run all checks
    $cpuStatus = Check-Cpu
    $memStatus = Check-Memory
    $diskStatus = Check-Disk
    $svcStatus = Check-Services
    
    # Determine overall status (highest severity wins)
    $maxStatus = @($cpuStatus, $memStatus, $diskStatus, $svcStatus) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    
    switch ($maxStatus) {
        0 { Write-Log "All systems OK" "INFO" }
        1 { Write-Log "One or more warnings detected" "WARN" }
        2 { Write-Log "Critical issues detected" "CRIT" }
    }
    
    Write-Log "System health check completed" "INFO"
    return $maxStatus
}

# Execute main function
Main
exit $LASTEXITCODE