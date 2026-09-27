This is the checklist for what the vcpkg team does when updating the macOS machines in the pool.

The hosts do not accept incoming SSH connections. Perform all host-side work in a terminal opened
through the KVM. Use the KVM software's "paste from clipboard" function to transfer commands and
short-lived credentials to the host. SSH commands in this document connect from the host to its
guest VM, not from a developer workstation to the host.

Before publishing the VM update changes, update the Azure Agent URI in
`scripts/azure-pipelines/osx/guest-prepare.sh` to the current version. You can find this by going to the
agent pool, selecting "New agent", picking macOS, and copying the link. For example:
https://download.agent.dev.azure.com/agent/5.277.0/vsts-agent-osx-arm64-5.277.0.tar.gz

Install and enable Homebrew on each host before cloning vcpkg:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Publish the changes to a fork and branch that the hosts can access. Keep a clone of
`microsoft/vcpkg` on each host as `origin`, add the operator's fork as a separate remote, and check
out the working revision to provide the scripts used by these instructions:

```sh
git clone https://github.com/microsoft/vcpkg ~/vcpkg
git -C ~/vcpkg remote add <WORKING-REMOTE> https://github.com/<GITHUB-USER>/vcpkg
git -C ~/vcpkg fetch <WORKING-REMOTE> <WORKING-BRANCH>
git -C ~/vcpkg checkout --detach FETCH_HEAD
```

For example, BillyONeal's fork should be added as remote `BillyONeal` with URL
`https://github.com/BillyONeal/vcpkg`. Do not use `origin` for the working branch unless the changes
have already been merged into `microsoft/vcpkg`. If the working branch is updated, repeat the
`fetch` and detached `checkout` commands above on each host.

## Creating new base images

### Prerequisites

- [ ] The matching macOS IPSW, Xcode 26.6 `.xip`, and Xcode 26.6 Command Line Tools `.dmg`
    uploaded to the `assets` container in the `vcpkgimageminting` storage account.
- [ ] PowerShell 7.x, Azure CLI, and `az login` with your Microsoft corp credentials on a workstation
    that can mint SAS tokens for the storage account.

### Instructions (ARM64)

- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues , pick the current osx queue,
      and delete one of the agents that are idle.
- [ ] Go to that machine in the KVM. (Passwords are stored as secrets in the CPP_GITHUB\vcpkg\vcpkgmm-passwords key vault)
- [ ] Update the macos host
- [ ] Prepare the host. This enables Homebrew, installs AzCopy if needed, and installs `macosvm` to `~`:
    ```sh
    ~/vcpkg/scripts/azure-pipelines/osx/host-prepare.sh
    ```
- [ ] On a workstation, generate download commands with short-lived, blob-scoped credentials for
    the matching IPSW, Xcode archive, and Command Line Tools installer in the `assets` container:
    ```powershell
    function Get-AssetDownloadCommand {
        Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$FileName)
        $accountName = 'vcpkgimageminting'
        $containerName = 'assets'
        $uNow = (Get-Date).ToUniversalTime()
        $start = $uNow.ToString('s') + 'Z'
        $expiry = $uNow.AddHours(1).ToString('s') + 'Z'
        $sas = az storage blob generate-sas --as-user --auth-mode login --account-name $accountName --container-name $containerName --name $FileName --permissions r --start $start --expiry $expiry --https-only --output tsv
        return "azcopy copy `"https://vcpkgimageminting.blob.core.windows.net/assets/$($FileName)?$($sas)`" `"$FileName`""
    }

    Get-AssetDownloadCommand -FileName UniversalMac_26.6.1_25G76_Restore.ipsw
    Get-AssetDownloadCommand -FileName Xcode_26.6_Apple_silicon.xip
    Get-AssetDownloadCommand -FileName Command_Line_Tools_26.6_Apple_silicon.dmg
    ```
    This creates a user-delegation SAS for each blob. Each credential is read-only, HTTPS-only, and
    valid for one hour. A SAS is not single-use and can be reused until it expires, so do not retain
    the generated commands after the downloads finish.
    If a matching IPSW has not yet been added to the container, use the
    [M4 Apple Silicon IPSW firmware database](https://mrmacintosh.com/apple-silicon-m1-full-macos-restore-ipsw-firmware-files-database/)
    to locate it and upload it first.
- [ ] In the host's KVM terminal, change to `~`, then use the KVM software's "paste from
      clipboard" function to paste and run each generated command:
    ```sh
    cd ~
    # Paste and run the three azcopy commands generated on the workstation.
    ```
- [ ] Determine the VM directory name using the form "vcpkg-osx-YYYY-MM-DD-arm64", for example "vcpkg-osx-2026-08-07-arm64".
- [ ] Open a terminal and run the following commands to create the VM with vcpkg-osx-YYYY-MM-DD-arm64 and UniversalMac_26.6.1_25G76_Restore.ipsw replaced as appropriate. This must be run in the KVM as it uses a GUI:
    ```
    mkdir -p ~/vcpkg-osx-YYYY-MM-DD-arm64
    cd ~/vcpkg-osx-YYYY-MM-DD-arm64
    ~/macosvm --disk disk.img,size=500g,sync=none,cache=cached --aux aux.img -c 10 -r 18g --restore ~/UniversalMac_26.6.1_25G76_Restore.ipsw ./vm.json
    ~/macosvm -g ./vm.json
    ```
- [ ] Follow prompts as you would on real hardware.
    * Set up as new.
    * Account name: builduser
    * A very similar password
    * Do not allow computer account password to be reset with your Apple Account.
    * Apple ID: 'Set Up Later' / Skip
    * No location services
    * Yes send crash reports
    * Set up screen time later
    * Only download updates automatically
- [ ] Set the desktop wallpaper to a fixed color from Settings -> Wallpaper . (This makes the KVM a lot easier to use :) )
- [ ] Disable automatic updates in the VM: Settings -> General -> Automatic Updates -> Disable them all
- [ ] Enable remote login in the VM: Settings -> General -> Sharing -> Remote Login
- [ ] Install Xcode from the host's vcpkg clone. This prompts for the guest password to install an
    SSH key and enable passwordless sudo, then transfers and expands Xcode:
    ```sh
    cd ~/vcpkg/scripts/azure-pipelines/osx
    ./host-install-xcode.sh
    ```
- [ ] Open Xcode from Applications in the guest GUI. Uncheck the "code completion model" and accept the EULA.
- [ ] After completing the Xcode GUI step, run the guest preparation script. It installs the Command
    Line Tools, build dependencies, and the Azure Pipelines agent:
    ```sh
    cd ~/vcpkg/scripts/azure-pipelines/osx
    ./host-prepare-guest.sh
    ```
- [ ] Shut down the VM cleanly.
- [ ] Delete the temporary installation assets from the host:
    ```sh
    rm ~/UniversalMac_26.6.1_25G76_Restore.ipsw \
        ~/Xcode_26.6_Apple_silicon.xip \
        ~/Command_Line_Tools_26.6_Apple_silicon.dmg
    ```
- [ ] In the host's KVM terminal, package the VM into an archive:
    ```sh
    cd ~
    aa archive -d vcpkg-osx-YYYY-MM-DD-arm64 -o vcpkg-osx-YYYY-MM-DD-arm64.aar -enable-holes
    ```
- [ ] In PowerShell on a workstation, generate the AzCopy upload command:
    ```powershell
    function Get-AzCopyWriteCommand {
        Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$FileName)
        $accountName = 'vcpkgimageminting'
        $containerName = 'pvms'
        $uNow = (Get-Date).ToUniversalTime()
        $start = $uNow.ToString('s') + 'Z'
        $expiry = $uNow.AddHours(1).ToString('s') + 'Z'
        $sas = az storage blob generate-sas --as-user --auth-mode login --account-name $accountName --container-name $containerName --name $FileName --permissions cw --start $start --expiry $expiry --https-only --output tsv
        return "azcopy copy  --check-length=false `"$($FileName)`" `"https://vcpkgimageminting.blob.core.windows.net/pvms/$($FileName)?$($sas)`""
    }

    Get-AzCopyWriteCommand -FileName vcpkg-osx-YYYY-MM-DD-arm64.aar
    ```
- [ ] Paste and run the generated AzCopy command in the host's KVM terminal.
- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues and create a new self hosted Agent pool named `PrOsx-YYYY-MM-DD-arm64`. Grant microsoft.vcpkg.ci and microsoft.vcpkg.pr access.
- [ ] Follow the "Deploying images" steps below for each machine in the fleet.

## Deploying images

### Running the VM

Run these steps on each machine to add to the fleet. Skip steps that were done implicitly above if this machine was used to build a box.

- [ ] If this machine was used before, delete it from the pool of which it is a member from https://dev.azure.com/vcpkg/public/_settings/agentqueues
- [ ] Log in to the machine using the KVM.
- [ ] Check for software updates in macOS system settings
- [ ] Ensure the host's vcpkg clone is at the published working revision, then prepare the host. This
    enables Homebrew, installs AzCopy if needed, and installs `macosvm` to `~`:
    ```sh
    git -C ~/vcpkg fetch <WORKING-REMOTE> <WORKING-BRANCH>
    git -C ~/vcpkg checkout --detach FETCH_HEAD
    ~/vcpkg/scripts/azure-pipelines/osx/host-prepare.sh
    ```
- [ ] Skip if this is the image building machine. In PowerShell on a workstation, mint a SAS token
    and generate the AzCopy command with:
    ```powershell
    function Get-AzCopyReadCommand {
        Param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$FileName)
        $accountName = 'vcpkgimageminting'
        $containerName = 'pvms'
        $uNow = (Get-Date).ToUniversalTime()
        $start = $uNow.ToString('s') + 'Z'
        $expiry = $uNow.AddHours(1).ToString('s') + 'Z'
        $sas = az storage blob generate-sas --as-user --auth-mode login --account-name $accountName --container-name $containerName --name $FileName --permissions r --start $start --expiry $expiry --https-only --output tsv
        return "azcopy copy `"https://vcpkgimageminting.blob.core.windows.net/pvms/$($FileName)?$($sas)`" `"$($FileName)`""
    }

    Get-AzCopyReadCommand -FileName vcpkg-osx-YYYY-MM-DD-arm64.aar
    ```
    In the host's KVM terminal, use the KVM software's "paste from clipboard" function to paste and
    run the generated command, then run:
    ```sh
    # (The azcopy command line generated above)
    aa extract -d vcpkg-osx-YYYY-MM-DD-arm64 -i ./vcpkg-osx-YYYY-MM-DD-arm64.aar -enable-holes
    ```
- [ ] Open a separate terminal window on the host and start the VM by running:
    ```sh
    cd ~/vcpkg-osx-YYYY-MM-DD-arm64
    ~/macosvm ./vm.json
    ```
- [ ] In PowerShell on a workstation, generate a short-lived access token to add the agent to the
    pool:
    ```pwsh
    az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 --query accessToken --output tsv
    ```
- [ ] In the host's KVM terminal, use the KVM software's "paste from clipboard" function to paste
    the short-lived access token into the guest deploy command from the vcpkg clone. The script
    accepts a host name in the form `vcpkg-m4-NNN` case-insensitively, registers the Azure DevOps
    agent as `VCPKG-M4-NNN`, and stops with an error if the host name or agent pool cannot be
    determined unambiguously:
    ```sh
    ~/vcpkg/scripts/azure-pipelines/osx/host-register-guest.sh TOKEN-GOES-HERE
    ```
- [ ] After successful registration, the script will cleanly shut down the VM. If registration fails,
      the VM remains running for diagnosis. In the KVM's terminal, relaunch the successfully registered
      VM in ephemeral mode:
    ```sh
    ~/macosvm --ephemeral ./vm.json
    ```
- [ ] Open a terminal window on the host and run the agent
    ```sh
    ssh -i ~/vcpkg-osx-*-arm64/id_guest builduser@buildusers-Virtual-Machine.local
    ~/myagent/run.sh
    ```
- [ ] Check that the machine shows up in the pool, and lock the current user account on the host.
- [ ] Lock the screen on the host.
- [ ] Update the "vcpkg Macs" spreadsheet line for the machine with the new pool.
