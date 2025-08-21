Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Pat,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Target
)

$sshCookie = "vcpkg@$Target"
scp "$PSScriptRoot/register-guest.sh" "$($sshCookie):/Users/vcpkg/register-guest.sh"

$script = @"
rm .ssh/known_hosts
chmod +x /Users/vcpkg/register-guest.sh
/Users/vcpkg/register-guest.sh $Pat
rm /Users/vcpkg/register-guest.sh
"@

$script | ssh $sshCookie
