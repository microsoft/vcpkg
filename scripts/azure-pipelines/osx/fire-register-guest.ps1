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

# note that the empty line is load bearing
$script = @"
rm .ssh/known_hosts
chmod +x /Users/vcpkg/register-guest.sh
/Users/vcpkg/register-guest.sh $Pat

"@

$script | ssh $sshCookie
ssh $sshCookie rm /Users/vcpkg/register-guest.sh
