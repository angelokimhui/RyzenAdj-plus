<#
.SYNOPSIS
    Automates ryzenAdj calls based on custom conditions
.DESCRIPTION
    This script is designed to provide maximum flexibility to the user. For that reason it does not use parameters.
    Instead of parameters, you need to populate the functions in the configuration section with your custom adjustments and additional custom code.
.NOTES
    SPDX-License-Identifier: LGPL
    Falco Schaffrath <falco.schaffrath@gmail.com>
#>

Param([Parameter(Mandatory=$false)][switch]$noGUI)
$Error.Clear()
################################################################################
#### Configuration Start
################################################################################
# WARNING: Use at your own risk!

$pathToRyzenAdjDlls = Split-Path -Parent $PSCommandPath #script path is DLL path, needs to be absolut path if you define something else

$showErrorPopupsDuringInit = $true
# debug mode prints adjust success messages too instead of errorss only
$debugMode = $false
# some Zen3 devices have a locked STAPM limit, this workarround resets the stapm timer to have unlimited stapm. Use max stapm_limit and stapm_time (usually 500) to triger as less resets as possible
$resetSTAPMUsage = $true

# Undervolt -30 on all cores
# Start-Process -NoNewWindow -Wait -filePath "C:\Data\Programs\RyzenADJ\ryzenadj.exe" -ArgumentList("--set-coper=0x0FFFCE")
# Start-Process -NoNewWindow -Wait -filePath "C:\Data\Programs\RyzenADJ\ryzenadj.exe" -ArgumentList("--set-coper=0x1FFFCE")
# Start-Process -NoNewWindow -Wait -filePath "C:\Data\Programs\RyzenADJ\ryzenadj.exe" -ArgumentList("--set-coper=0x2FFFCE")
# Start-Process -NoNewWindow -Wait -filePath "C:\Data\Programs\RyzenADJ\ryzenadj.exe" -ArgumentList("--set-coper=0x3FFFCE")
# Start-Process -NoNewWindow -Wait -filePath "C:\Data\Programs\RyzenADJ\ryzenadj.exe" -ArgumentList("--set-coper=0x4FFFCE")
# Start-Process -NoNewWindow -Wait -filePath "C:\Data\Programs\RyzenADJ\ryzenadj.exe" -ArgumentList("--set-coper=0x5FFFCE")

# SET PROFILE TO 25 OR MORE WATTS in SMOKELESS UMAF OR BIOS

function doAdjust_ryzenadj {
    $Script:repeatWaitTimeSeconds = 10    #only use values below 5s if you are using $monitorField
    enable "max_performance"
    # enable "power_saving"
    adjust "stapm_limit" 65000
    adjust "fast_limit" 25000
    adjust "slow_limit" 25000
    adjust "slow_time" 500
    adjust "prochot_deassertion_ramp" 1
    adjust "tctl_temp" 90
    adjust "apu_skin_temp_limit" 50
    adjust "stapm_time" 500
    # adjust "vrmmax_current" 80000
    # adjust "vrmsocmax_current" 30000
    # adjust "vrm_current" 40000
    # adjust "vrmsoc_current" 20000
    # adjust "coall" 1048555
}
################################################################################
#### Configuration End
################################################################################

$env:PATH += ";$pathToRyzenAdjDlls"
$NL = $([System.Environment]::NewLine);

if($noGUI){ $showErrorPopupsDuringInit = $false }

$apiHeader = @'
[DllImport("libryzenadj.dll")] public static extern IntPtr init_ryzenadj();
[DllImport("libryzenadj.dll")] public static extern int set_stapm_limit(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_fast_limit(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_slow_limit(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_slow_time(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_stapm_time(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_tctl_temp(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_vrm_current(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_vrmsoc_current(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_vrmmax_current(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_vrmsocmax_current(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_psi0_current(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_psi0soc_current(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_max_gfxclk_freq(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_min_gfxclk_freq(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_max_socclk_freq(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_min_socclk_freq(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_max_fclk_freq(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_min_fclk_freq(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_max_vcn(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_min_vcn(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_max_lclk(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_min_lclk(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_prochot_deassertion_ramp(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_apu_skin_temp_limit(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_dgpu_skin_temp_limit(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_apu_slow_limit(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_power_saving(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern int set_max_performance(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern int set_coall(IntPtr ry, [In]uint value);
[DllImport("libryzenadj.dll")] public static extern int set_coper(IntPtr ry, [In]uint value);

[DllImport("libryzenadj.dll")] public static extern int refresh_table(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern IntPtr get_table_values(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_stapm_limit(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_stapm_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_stapm_time(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_fast_limit(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_fast_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_slow_limit(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_slow_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_apu_slow_limit(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_apu_slow_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrm_current(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrm_current_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrmsoc_current(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrmsoc_current_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrmmax_current(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrmmax_current_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrmsocmax_current(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_vrmsocmax_current_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_tctl_temp(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_tctl_temp_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_apu_skin_temp_limit(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_apu_skin_temp_value(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_dgpu_skin_temp_limit(IntPtr ry);
[DllImport("libryzenadj.dll")] public static extern float get_dgpu_skin_temp_value(IntPtr ry);

[DllImport("kernel32.dll")] public static extern uint GetModuleFileName(IntPtr hModule, [Out]StringBuilder lpFilename, [In]int nSize);

public static String getExpectedWinRing0DriverFilepath(){
    StringBuilder fileName = new StringBuilder(255);
    GetModuleFileName(IntPtr.Zero, fileName, fileName.Capacity);
    return Path.GetDirectoryName(fileName.ToString()) + "\\WinRing0x64.sys";
}

public static String getDllImportErrors(){
    try {
        Marshal.PrelinkAll(typeof(adj));
    } catch (Exception e) {
        return e.Message;
    }
    return "";
}
'@

if(-not ([System.Management.Automation.PSTypeName]'ryzen.adj').Type){
    Add-Type -MemberDefinition $apiHeader -Namespace 'ryzen' -Name 'adj' -UsingNamespace ('System.Text', 'System.IO')
}

Add-Type -AssemblyName System.Windows.Forms
function showErrorMsg ([String] $msg){
    if($showErrorPopupsDuringInit){
        [void][System.Windows.Forms.MessageBox]::Show($msg, $PSCommandPath,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

$dllImportErrors = [ryzen.adj]::getDllImportErrors();
if($dllImportErrors -or $Error){
    Write-Error $dllImportErrors
    showErrorMsg "Problem with using libryzenadj.dll$NL$NL$($Error -join $NL)"
    exit 1
}

$winring0DriverFilepath = [ryzen.adj]::getExpectedWinRing0DriverFilepath()
if(!(Test-Path $winring0DriverFilepath)) { Copy-Item -Path $pathToRyzenAdjDlls\WinRing0x64.sys -Destination $winring0DriverFilepath }

$ry = [ryzen.adj]::init_ryzenadj()
if($ry -eq 0){
    $msg = "RyzenAdj could not get initialized.$($NL)Reason can be found inside Powershell$($NL)"
    if($psISE) { $msg += "It is not possible to see the error reason inside ISE, you need to test it in PowerShell Console" }
    showErrorMsg "$msg$NL$NL$($Error -join $NL)"
    exit 1
}

function adjust ([String] $fieldName, [uInt32] $value) {
    if($fieldName -eq $Script:monitorField) {
        $newTargetValue = [math]::round($value * 0.001, 3, 0)
        if($Script:monitorFieldAdjTarget -ne $newTargetValue){
            $Script:monitorFieldAdjTarget = $newTargetValue
            Write-Host "set new monitoring target $fieldName to $newTargetValue"
        }
    }
    $res = Invoke-Expression "[ryzen.adj]::set_$fieldName($ry, $value)"
    switch ($res) {
        0 {
            if($debugMode) { Write-Host "set $fieldName to $value" }
            return
        }
        -1 { Write-Error "set_$fieldName is not supported on this family"}
        -3 { Write-Error "set_$fieldName is not supported on this SMU"}
        -4 { Write-Error "set_$fieldName is rejected by SMU"}
        default { Write-Error "set_$fieldName did fail with $res"}
    }
}

function enable ([String] $fieldName) {
    $res = Invoke-Expression "[ryzen.adj]::set_$fieldName($ry)"
    switch ($res) {
        0 {
            if($debugMode) { Write-Host "enable $fieldName"}
            return
        }
        -1 { Write-Error "set_$fieldName is not supported on this family"}
        -3 { Write-Error "set_$fieldName is not supported on this SMU"}
        -4 { Write-Error "set_$fieldName is rejected by SMU"}
        default { Write-Error "set_$fieldName did fail with $res"}
    }
}

function testMonitorField {
    if($monitorField -and $Script:monitorFieldAdjTarget -eq 0){
        Write-Error ("You forgot to set $monitorField in your profile.$NL$NL" +
            "If you ignore it, the script will apply values unnessasary often.$NL")
    }
}

function updateMonitorFieldAdjResult {
    if($monitorField){
        [void][ryzen.adj]::refresh_table($ry)
        $Script:monitorFieldAdjResult = [math]::round((getMonitorValue), 3, 0)
        if($Script:monitorFieldAdjTarget -ne $Script:monitorFieldAdjResult){
            Write-Host ("Warning - $monitorField adjust result $Script:monitorFieldAdjResult does not match target value $Script:monitorFieldAdjTarget. Value $Script:monitorFieldAdjResult will be used for monitoring")
        }
    }
}

function testConfiguration {
    Write-Host "Test Adjustments"
    doAdjust_ryzenadj
    testMonitorField
    $Script:monitorFieldAdjTarget = 0
    updateMonitorFieldAdjResult

    if($Error -and $showErrorPopupsDuringInit){
        $answer = [System.Windows.Forms.MessageBox]::Show("Your Adjustment configuration did not work.$NL$NL$($Error -join $NL)", $PSCommandPath,
            [System.Windows.Forms.MessageBoxButtons]::AbortRetryIgnore,
            [System.Windows.Forms.MessageBoxIcon]::Warning)
        $Error.Clear()
        if($answer -eq "Abort"){ exit 1 }
        if($answer -eq "Retry"){ testConfiguration }
    }
}

function resetSTAPMIfNeeded {
    $stapm_limit = [ryzen.adj]::get_stapm_limit($ry)
    $stapm_value = [ryzen.adj]::get_stapm_value($ry)
    $stapm_hysteresis = 1 #Throttling starts arround ~0.9W before limit

    if ($stapm_value -gt ($stapm_limit - $stapm_hysteresis)) {
        $stapm_time = [ryzen.adj]::get_stapm_time($ry)
        $reduced_stapm_limit = ($stapm_limit - 5) #reduce stapm by 5W
        # Write-Host "[STAPM_RESET] stapm_value ($stapm_value) nearing stapm_limit ($stapm_limit), resetting..."
        [void][ryzen.adj]::set_stapm_limit($ry, ($reduced_stapm_limit) * 1000)
        [void][ryzen.adj]::set_stapm_time($ry, 0)
        [Threading.Thread]::Sleep(10) #10ms is usually enough time
        [void][ryzen.adj]::set_stapm_time($ry, $stapm_time)
        [void][ryzen.adj]::set_stapm_limit($ry, $stapm_limit * 1250) # add 25% STAPM limit in case we are at battery saving mode where applied values get reduced by 10% or 20%
    }
}

if(-not $Script:repeatWaitTimeSeconds) { $Script:repeatWaitTimeSeconds = 5 }
$Script:monitorFieldAdjResult = 0; #adjust result will be used for monitoring because SMU may only set 90% and 80% of your value
$Script:monitorFieldAdjTarget = 0;

testConfiguration

<# Example how to get 560 lines of ptable
$pmTable = [float[]]::new(560)
$tablePtr = [ryzen.adj]::get_table_values($ry);
[System.Runtime.InteropServices.Marshal]::Copy($tablePtr, $pmTable, 0, 560);
#>
$processType = "Apply Settings"

Write-Host "$processType every $Script:repeatWaitTimeSeconds seconds..."
while($true) {

        $oldWait = $Script:repeatWaitTimeSeconds
        doAdjust_ryzenadj
        updateMonitorFieldAdjResult
        if($resetSTAPMUsage){
            resetSTAPMIfNeeded
        }
        if($oldWait -ne $Script:repeatWaitTimeSeconds ) { Write-Host "$processType every $Script:repeatWaitTimeSeconds seconds..." }

    sleep $Script:repeatWaitTimeSeconds
}
