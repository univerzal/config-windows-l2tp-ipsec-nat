# Configuration for Windows L2TP/IPSEC VPN client connections behind a NAT
# References: 
# http://woshub.com/l2tp-ipsec-vpn-server-behind/
# https://superuser.com/a/532109

$OSVersion = [Environment]::OSVersion.Version;
$OSName = gwmi win32_operatingsystem | % caption;

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

if ($OSVersion -eq ((New-object 'Version' 5,1) -or (New-object 'Version' 5,2))) {
    Write-Output "Detected $OSName.";
    Write-Output "Enabling NAT-T for L2TP/IPSEC...";
    Set-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Services\IPSec" -Name "AssumeUDPEncapsulationContextOnSendRule" -Type DWORD -Value 2 –Force;
    Write-Output "Registry key and value written.";
}
elseif ($OSVersion -ge (New-Object 'Version' 6,0))  {
    Write-Output "Detected $OSName.";
    Write-Output "Enabling NAT-T for L2TP/IPSEC...";
    Set-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Services\PolicyAgent" -Name "AssumeUDPEncapsulationContextOnSendRule" -Type DWORD -Value 2 –Force;
    Write-Output "Registry key and value written.";
} else {
    Write-Output "Not supported operating system detected: $OSName.";
    Write-Output "Exiting.";
}
Write-Host "Press any key to continue ..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
