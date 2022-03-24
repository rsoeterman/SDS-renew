# Replace IndigoVision Site Database certificate if the certificate is automatically renewed by the CA

# Retrieve current certificate from certificate store
$localcerts = (Get-ChildItem  -Path Cert:\LocalMachine\MY | Where-Object {$_.Subject -Match "$env:COMPUTERNAME"})
$certcount = $localcerts.Count

# Retrieve current certificate used by SDS
$certsdsthumb = (Get-ItemProperty "HKLM:\SOFTWARE\IndigoVision\Site Database Server").CertificateDetails

# This script only works if there's only one certificate with the computername in it
If ($certcount -eq 1) {
    $certthumb = $localcerts.Thumbprint

    If (-NOT  ($certsdsthumb -eq $certthumb)) {
	      Set-ItemProperty -Path "HKLM:\SOFTWARE\IndigoVision\Site Database Server" -Name "CertificateDetails" -Value $certthumb
	      Restart-Service -Name IVSDS
        Write-Output "Certificate successfully replaced for $env:COMPUTERNAME" >> cert-renew.log
    }
}
If ($certcount -gt 1) {
    Write-Output "ERROR: Too many certificates on $env:COMPUTERNAME. Remove unused certificates from client." >> cert-renew.log
}
