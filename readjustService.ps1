<#
.SYNOPSIS
    Automates RyzenAdj calls based on custom conditions
.DESCRIPTION
    This script provides flexibility to the user by allowing function-based configuration instead of parameters.
.NOTES
    SPDX-License-Identifier: LGPL
    Falco Schaffrath <falco.schaffrath@gmail.com>
#>

Param([switch]$noGUI)
$Error.Clear()

# Configuration Start
$pathToRyzenAdjDlls = Split-Path -Parent $PSCommandPath
$showErrorPopupsDuringInit = $true
$resetSTAPMUsage = $true

function doAdjust_ryzenadj {
    $Script:repeatWaitTimeSeconds = 10
    enable "max_performance"
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

if (-not ([System.Management.Automation.PSTypeName]'ryzen.adj').Type) {
    Add-Type -MemberDefinition $apiHeader -Namespace 'ryzen' -Name 'adj' -UsingNamespace ('System.Text', 'System.IO')
}

Add-Type -AssemblyName System.Windows.Forms

function showErrorMsg ($msg) {
    if ($showErrorPopupsDuringInit) {
        [System.Windows.Forms.MessageBox]::Show($msg, $PSCommandPath, 'OK', 'Error')
    }
}

$dllImportErrors = [ryzen.adj]::getDllImportErrors()
if ($dllImportErrors) {
    Write-Error $dllImportErrors
    showErrorMsg "Problem with libryzenadj.dll$NL$($dllImportErrors)"
    exit 1
}

$winring0DriverFilepath = [ryzen.adj]::getExpectedWinRing0DriverFilepath()
if (!(Test-Path $winring0DriverFilepath)) {
    Copy-Item -Path "$pathToRyzenAdjDlls\WinRing0x64.sys" -Destination $winring0DriverFilepath
}

$ry = [ryzen.adj]::init_ryzenadj()
if ($ry -eq 0) {
    $msg = "RyzenAdj initialization failed."
    showErrorMsg "$msg$NL$($Error -join $NL)"
    exit 1
}

function adjust ($fieldName, $value) {
    Invoke-Expression "[ryzen.adj]::set_$fieldName($ry, $value)" | Out-Null
}

function enable ($fieldName) {
    Invoke-Expression "[ryzen.adj]::set_$fieldName($ry)" | Out-Null
}

function resetSTAPMIfNeeded {
    $stapm_limit = [ryzen.adj]::get_stapm_limit($ry)
    $stapm_value = [ryzen.adj]::get_stapm_value($ry)

    if ($stapm_value -gt ($stapm_limit - 1)) {
        $stapm_time = [ryzen.adj]::get_stapm_time($ry)
        adjust "stapm_limit" ($stapm_limit - 5) * 1000
        adjust "stapm_time" 0
        Start-Sleep -Milliseconds 10
        adjust "stapm_time" $stapm_time
        adjust "stapm_limit" $stapm_limit * 1250
    }
}

doAdjust_ryzenadj

Write-Host "Applying settings every $Script:repeatWaitTimeSeconds seconds..."

while ($true) {
    doAdjust_ryzenadj
    if ($resetSTAPMUsage) { resetSTAPMIfNeeded }
    Start-Sleep -Seconds $Script:repeatWaitTimeSeconds
}