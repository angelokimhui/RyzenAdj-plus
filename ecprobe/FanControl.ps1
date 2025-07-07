<#
.SYNOPSIS
    Automates ecprobe calls based on custom conditions.
.NOTES
    SPDX-License-Identifier: LGPL
    Angelo Kim Hui Lim <angelokimhui@gmail.com>
#>

# Fix CPU Util bug after bootup
Start-Sleep -Seconds 1

# Load the hardware monitor library
Add-Type -Path "$PSScriptRoot\Plugins\OpenHardwareMonitorLib.dll"
$hwmon = New-Object -TypeName OpenHardwareMonitor.Hardware.Computer
$hwmon.CPUEnabled = $true
$hwmon.Open()

[Int]$currentFS = -1

# Function to update fan speed if necessary
function Set-FanSpeed {
    param (
        [int]$newSpeed
    )
    if ($currentFS -ne $newSpeed) {
        $currentFS = $newSpeed
        Start-Process -WindowStyle Hidden -Wait -FilePath "$PSScriptRoot\ec-probe.exe" -ArgumentList("write", "44", "$newSpeed")
    }
}

# Monitor CPU temperature and adjust fan speed accordingly
foreach ($hardwareItem in $hwmon.Hardware) {
    if ($hardwareItem.HardwareType -eq [OpenHardwareMonitor.Hardware.HardwareType]::CPU) {
        $hardwareItem.Update()

        foreach ($sensor in $hardwareItem.Sensors) {
            if ($sensor.SensorType -eq "Temperature") {
                while ($true) {
                    $hardwareItem.Update()
                    $temperature = $sensor.Value

                    switch ($temperature) {
                        {$_ -le 50} {
                            Set-FanSpeed 0
                            while ($sensor.Value -le 50) {
                                $hardwareItem.Update()
                                Start-Sleep -Seconds 5
                            }
                        }
                        {$_ -le 55} {
                            Set-FanSpeed 30
                            while ($sensor.Value -lt 60 -and $sensor.Value -gt 50) {
                                $hardwareItem.Update()
                                Start-Sleep -Seconds 1
                            }
                        }
                        {$_ -le 60} {
                            Set-FanSpeed 50
                            while ($sensor.Value -lt 70 -and $sensor.Value -gt 55) {
                                $hardwareItem.Update()
                                Start-Sleep -Seconds 5
                            }
                        }
                        {$_ -le 70} {
                            Set-FanSpeed 95
                            while ($sensor.Value -lt 75 -and $sensor.Value -gt 65) {
                                $hardwareItem.Update()
                                Start-Sleep -Seconds 10
                            }
                        }
                        default {
                            Set-FanSpeed 100
                            while ($sensor.Value -gt 60) {
                                $hardwareItem.Update()
                                Start-Sleep -Seconds 20
                            }
                        }
                    }
                }
            }
        }
    }
}

$hwmon.Close()
