# `vcpkg-eg-mac` VMs

This is the checklist for what the vcpkg team does when updating the macOS machines in the pool.

## Creating new base images

### Prerequisites

- [ ] [macosvm](https://github.com/s-u/macosvm) allow-listed
  by macOS for arm64.
- [ ] An Xcode 26.6 .xip - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>  
  If you are doing this from a local macos box, you can skip to the "update the macos host" step.  
- [ ] The Xcode 26.6 Command Line Tools installer
- [ ] PowerShell 7.x, Azure CLI, and `az login` with your Microsoft corp credentials

### Instructions (ARM64)

- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues , pick the current osx queue,
      and delete one of the agents that are idle.
- [ ] Go to that machine in the KVM. (Passwords are stored as secrets in the CPP_GITHUB\vcpkg\vcpkgmm-passwords key vault)
- [ ] Update the macos host
- [ ] (Once only) install `macosvm` to `~` (this tarball is also backed up in our `vcpkg-image-minting` storage account). For example from a dev workstation:
    ```
    ssh vcpkg@HOSTMACHINE
    curl -L -o macosvm-0.2-3-darwin21.tar.gz https://github.com/s-u/macosvm/releases/download/0.2-3/macosvm-0.2-3-darwin21.tar.gz
    tar xvf macosvm-0.2-3-darwin21.tar.gz
    rm macosvm-0.2-3-darwin21.tar.gz
    exit
    ```
- [ ] Download the matching `.ipsw` for the macOS copy to install. See https://mrmacintosh.com/apple-silicon-m1-full-macos-restore-ipsw-firmware-files-database/ ; links there to find the .ipsw. Example:
    https://updates.cdn-apple.com/2026SummerFCS/fullrestores/140-65618/10445B26-DE2C-43EC-9149-0A831602E74B/UniversalMac_26.6_25G72_Restore.ipsw
- [ ] Determine the VM directory name using the form "vcpkg-osx-<date>-arm64", for example "vcpkg-osx-2026-07-29-arm64".
- [ ] Open a terminal and run the following commands to create the VM with vcpkg-osx-2026-07-29-arm64 and UniversalMac_26.6_25G72_Restore.ipsw replaced as appropriate. This must be run in the KVM as it uses a GUI:
    ```
    mkdir -p ~/vcpkg-osx-2026-07-29-arm64
    cd ~/vcpkg-osx-2026-07-29-arm64
    ~/macosvm --disk disk.img,size=500g --aux aux.img -c 8 -r 12g --restore ~/UniversalMac_26.6_25G72_Restore.ipsw ./vm.json
    ~/macosvm -g ./vm.json
    ```
- [ ] Follow prompts as you would on real hardware.
    * Set up as new.
    * Account name: vcpkg
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
- [ ] Set the vcpkg user to be able to use sudo without a password, and install Xcode. For example from a dev workstation:
    ```
    scp path/to/Xcode.xip vcpkg@HOSTMACHINE:/Users/vcpkg/Xcode.xip
    ssh vcpkg@HOSTMACHINE
    ssh-keygen -R vcpkgs-Virtual-Machine.local
    scp Xcode.xip vcpkg@vcpkgs-Virtual-Machine.local:/Users/vcpkg/Xcode.xip
    ssh vcpkg@vcpkgs-Virtual-Machine.local
    printf 'vcpkg\tALL=(ALL)\tNOPASSWD:\tALL\n' | sudo tee -a '/etc/sudoers.d/vcpkg'
    sudo chmod 0440 '/etc/sudoers.d/vcpkg'
    sudo mdutil -ad
    xip --expand Xcode.xip
    sudo mv Xcode.app /Applications/Xcode.app
    rm Xcode.xip
    exit
    ```
- [ ] Open Xcode from Applications in the guest GUI. Uncheck the "code completion model" and accept the EULA.
- [ ] Update the Azure Agent URI in setup-box.sh to the current version. You can find this by going to the agent pool, selecting "New agent", picking macOS, and copying the link. For example https://download.agent.dev.azure.com/agent/5.276.0/vsts-agent-osx-arm64-5.276.0.tar.gz
- [ ] Copy setup-box.sh and the xcode installer renamed to 'clt.dmg' to the host. For example from a dev workstation:
    ```
    scp ./setup-guest.sh vcpkg@HOSTMACHINE:/Users/vcpkg
    scp ./setup-box.sh vcpkg@HOSTMACHINE:/Users/vcpkg
    scp path/to/console/tools.dmg vcpkg@HOSTMACHINE:/Users/vcpkg/clt.dmg
    ssh vcpkg@HOSTMACHINE
    chmod +x setup-guest.sh
    ./setup-guest.sh && rm setup-guest.sh setup-box.sh clt.dmg
    exit
    ```
- [ ] Shut down the VM cleanly.
- [ ] Package the VM into a tarball and upload it to blob storage. From a dev workstation, get the azcopy command to do the upload with:
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

    Get-AzCopyWriteCommand -FileName vcpkg-osx-2026-07-29-arm64.aar
    ```
    Then:
    ```
    ssh vcpkg@HOSTMACHINE
    aa archive -d vcpkg-osx-<date>-arm64 -o vcpkg-osx-<date>-arm64.aar -enable-holes
    brew install azcopy
    # (The azcopy command line generated above)
    exit
    ```
- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues and create a new self hosted Agent pool named `PrOsx-YYYY-MM-DD-arm64` based on the current date. Grant microsoft.vcpkg.ci and microsoft.vcpkg.pr access.
- [ ] Follow the "Deploying images" steps below for each machine in the fleet.

## Deploying images

### Running the VM

Run these steps on each machine to add to the fleet. Skip steps that were done implicitly above if this machine was used to build a box.

- [ ] If this machine was used before, delete it from the pool of which it is a member from https://dev.azure.com/vcpkg/public/_settings/agentqueues
- [ ] Log in to the machine using the KVM.
- [ ] Check for software updates in macOS system settings
- [ ] (Once only) install `macosvm` to `~` (this tarball is also backed up in our `vcpkg-image-minting` storage account). From a developer machine:
    ```sh
    ssh vcpkg@HOSTMACHINE
    curl -L -o macosvm-0.2-3-darwin21.tar.gz https://github.com/s-u/macosvm/releases/download/0.2-3/macosvm-0.2-3-darwin21.tar.gz
    tar xvf macosvm-0.2-3-darwin21.tar.gz
    rm macosvm-0.2-3-darwin21.tar.gz
    exit
    ```
- [ ] Skip if this is the image building machine. Mint a SAS token URI to the box to use from the Azure portal if you don't already have one, and download the VM. (Recommend running this via SSH from domain joined machine due to containing SAS tokens). From a developer machine, get the azcopy command with:
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

    Get-AzCopyReadCommand -FileName vcpkg-osx-2026-07-29-arm64.aar
    ```
    Then run:
    ```sh
    ssh vcpkg@HOSTMACHINE
    brew install azcopy
    # (The azcopy command line generated above)
    aa extract -d vcpkg-osx-<DATE>-arm64 -i ./vcpkg-osx-<DATE>-arm64.aar -enable-holes
    exit
    ```
- [ ] Open a separate terminal window on the host and start the VM by running:
    ```sh
    cd ~/vcpkg-osx-<DATE>-arm64
    ~/macosvm ./vm.json
    ```
- [ ] Generate an access token to add the agent to the pool:
    ```pwsh
    az account get-access-token --resource 499b84ac-1321-427f-aa17-267ca6975798 --query accessToken --output tsv
    ```
- [ ] Copy the guest deploy script to the host, and run it with the access token/OAuth token from the `az account get-access-token` command above as the first parameter. From a developer machine pwsh:
    ```pwsh
    scp register-guest.sh vcpkg@HOSTMACHINE:/Users/vcpkg/register-guest.sh
    ssh vcpkg@HOSTMACHINE
    ssh-keygen -R vcpkgs-Virtual-Machine.local
    chmod +x register-guest.sh
    ./register-guest.sh TOKEN-GOES-HERE AGENT-NUMBER-GOES-HERE && rm register-guest.sh
    ```
- [ ] After successful registration, the script will cleanly shut down the VM. If registration fails,
      the VM remains running for diagnosis. In the KVM's terminal, relaunch a successfully registered VM in ephemeral mode with:
    ```sh
    ~/macosvm --ephemeral ./vm.json
    ```
- [ ] Open a terminal window on the host and run the agent
    ```sh
    ssh -i ~/vcpkg-osx-*-arm64/id_guest vcpkg@vcpkgs-Virtual-Machine.local
    ~/myagent/run.sh
    ```
- [ ] Check that the machine shows up in the pool, and lock the vcpkg user on the host.
- [ ] Lock the screen on the host.
- [ ] Update the "vcpkg Macs" spreadsheet line for the machine with the new pool.
