# According to:
#   https://www.openssl.org/docs/faq.html#USER16
# it is up to developers or admins to maintain CAs.
#
# This script imports LocalMachine certificates into rootcerts.pem
# needed by qca.
#
# PS> .\import-local-certificates.ps1 -certstore Root -outpath C:\src\git\vcpkg\ports\qca
#

param (
    # one of Root, My, CA, ...
    [string]$certstore = "Root",
    # the path where it should be in qca buildtree (without trailing '\')
    [Parameter(Mandatory=$true)][string]$outpath
)

$certs = (Get-ChildItem -Path 'Cert:\LocalMachine\Root')
$outfile = $outpath + "\rootcerts.pem"

Write-Host "Importing: " $certs.Count " certificates ..."

foreach ($cert in $certs)
{
    $certs.GetIssuerName()
    $out = New-Object String[] -ArgumentList 3
    $out[0] = "-----BEGIN CERTIFICATE-----"
    $out[1] = [System.Convert]::ToBase64String($cert.PublicKey.EncodedKeyValue.RawData, "InsertLineBreaks")
    $out[2] = "-----END CERTIFICATE-----"

    [System.IO.File]::AppendAllLines($outfile, $out)
}

Write-Host "Written to: " $outfile
Write-Host "Importing certificates done." 
