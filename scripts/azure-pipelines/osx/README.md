# `vcpkg-eg-mac` VMs

This is the checklist for what the vcpkg team does when updating the macOS machines in the pool.

## Creating new base images

### Prerequisites

- [ ] [macosvm](https://github.com/s-u/macosvm) allow-listed
  by macOS for arm64. Note that the directory 'Parallels' is still used when using `macosvm`
  just so that scripts know where to find the VM and friends.
- [ ] An Xcode .xip - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>  
  If you are doing this from a local macos box, you can skip to the "update the macos host" step.  
- [ ] An Xcode Command Line Tools installer

### Instructions (ARM64)

- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues , pick the current osx queue,
      and delete one of the agents that are idle.
- [ ] Go to that machine in the KVM. (Passwords are stored as secrets in the CPP_GITHUB\vcpkg\vcpkgmm-passwords key vault)
- [ ] Update the macos host
- [ ] (Once only) install `macosvm` to `~` (this tarball is also backed up in our `vcpkg-image-minting` storage account). For example from a dev workstation:
    ```sh
    ssh vcpkg@HOSTMACHINE
    curl -L -o macosvm-0.2-2-arm64-darwin21.tar.gz https://github.com/s-u/macosvm/releases/download/0.2-2/macosvm-0.2-2-arm64-darwin21.tar.gz
    tar xvf macosvm-0.2-2-arm64-darwin21.tar.gz
    rm macosvm-0.2-2-arm64-darwin21.tar.gz
    exit
    ```
- [ ] Download the matching `.ipsw` for the macOS copy to install. See https://mrmacintosh.com/apple-silicon-m1-full-macos-restore-ipsw-firmware-files-database/ ; links there to find the .ipsw. Example: https://updates.cdn-apple.com/2025FallFCS/fullrestores/093-37399/E144C918-CF99-4BBC-B1D0-3E739B9A3F2D/UniversalMac_26.2_25C56_Restore.ipsw
- [ ] Determine the VM name using the form "vcpkg-osx-<date>-arm64", for example "vcpkg-osx-2026-01-12-arm64".
- [ ] Open a terminal and run the following commands to create the VM with vcpkg-osx-2026-01-12-arm64 and UniversalMac_26.2_25C56_Restore.ipsw replaced as appropriate. This must be run in the KVM as it uses a GUI:
    ```sh
    mkdir -p ~/Parallels/vcpkg-osx-2026-01-12-arm64
    cd ~/Parallels/vcpkg-osx-2026-01-12-arm64
    ~/macosvm --disk disk.img,size=500g --aux aux.img -c 8 -r 12g --restore ~/UniversalMac_26.2_25C56_Restore.ipsw ./vm.json
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
    ```sh
    scp path/to/Xcode.xip vcpkg@HOSTMACHINE:/Users/vcpkg/Xcode.xip
    ssh vcpkg@HOSTMACHINE
    rm ~/.ssh/known_hosts
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
- [ ] Update the Azure Agent URI in setup-box.sh to the current version. You can find this by going to the agent pool, selecting "New agent", picking macOS, and copying the link. For example https://download.agent.dev.azure.com/agent/4.266.2/vsts-agent-osx-arm64-4.266.2.tar.gz
- [ ] Copy setup-box.sh and the xcode installer renamed to 'clt.dmg' to the host. For example from a dev workstation:
    ```sh
    scp ./setup-guest.sh vcpkg@HOSTMACHINE:/Users/vcpkg
    scp ./setup-box.sh vcpkg@HOSTMACHINE:/Users/vcpkg
    scp path/to/console/tools.dmg vcpkg@HOSTMACHINE:/Users/vcpkg/clt.dmg
    ssh vcpkg@HOSTMACHINE
    chmod +x setup-guest.sh
    ./setup-guest.sh
    rm setup-guest.sh
    rm setup-box.sh
    rm clt.dmg
    exit
    ```
- [ ] Shut down the VM cleanly.
- [ ] Mint a SAS token to vcpkgimageminting/pvms with read, add, create, write, and list permissions.
- [ ] Package the VM into a tarball. For example from a dev workstation:
    ```sh
    ssh vcpkg@HOSTMACHINE
    cd ~/Parallels
    aa archive -d vcpkg-osx-<date>-arm64 -o vcpkg-osx-<date>-arm64.aar -enable-holes
    brew install azcopy
    azcopy copy vcpkg-osx-<date>-arm64.aar "https://vcpkgimageminting.blob.core.windows.net/pvms?<SAS>"
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
    curl -L -o macosvm-0.2-2-arm64-darwin21.tar.gz https://github.com/s-u/macosvm/releases/download/0.2-2/macosvm-0.2-2-arm64-darwin21.tar.gz
    tar xvf macosvm-0.2-2-arm64-darwin21.tar.gz
    rm macosvm-0.2-2-arm64-darwin21.tar.gz
    exit
    ```
- [ ] Skip if this is the image building machine. Mint a SAS token URI to the box to use from the Azure portal if you don't already have one, and download the VM. (Recommend running this via SSH from domain joined machine due to containing SAS tokens). From a developer machine:
    ```sh
    ssh vcpkg@HOSTMACHINE
    brew install azcopy
    mkdir -p ~/Parallels
    cd ~/Parallels
    azcopy copy "https://vcpkgimageminting.blob.core.windows.net/pvms/vcpkg-osx-<DATE>-arm64.aar?<SAS>" vcpkg-osx-<DATE>-arm64.aar
    aa extract -d vcpkg-osx-<DATE>-arm64 -i ./vcpkg-osx-<DATE>-arm64.aar -enable-holes
    exit
    ```
- [ ] Open a separate terminal window on the host and start the VM by running:
    ```sh
    cd ~/Parallels/vcpkg-osx-<DATE>-arm64
    ~/macosvm ./vm.json
    ```
- [ ] [grab a PAT][] if you don't already have one
- [ ] Copy the guest deploy script to the host, and run it with a first parameter of your PAT. From a developer machine:
    ```sh
    scp register-guest.sh vcpkg@HOSTMACHINE:/Users/vcpkg/register-guest.sh
    ssh vcpkg@HOSTMACHINE
    rm .ssh/known_hosts
    chmod +x register-guest.sh
    ./register-guest.sh PAT-GOES-HERE AGENT-NUMBER-GOES-HERE
    rm register-guest.sh
    ```
- [ ] That will cleanly shut down the VM. In the KVM's terminal, relaunch the VM in ephemeral mode with:
    ```sh
    ~/macosvm --ephemeral ./vm.json
    ```
- [ ] Open a terminal window on the host and run the agent
    ```sh
    ssh -i ~/Parallels/*/id_guest vcpkg@vcpkgs-Virtual-Machine.local
    ~/myagent/run.sh
    ```
- [ ] Check that the machine shows up in the pool, and lock the vcpkg user on the host.
- [ ] Lock the screen on the host.
- [ ] Update the "vcpkg Macs" spreadsheet line for the machine with the new pool.

[grab a PAT]: #getting-an-azure-pipelines-pat

## Getting an Azure Pipelines PAT

Personal Access Tokens are an important part of this process,
and they are fairly easy to generate.
On ADO, under the correct project (in vcpkg's case, "vcpkg"),
click on the "User Settings" icon, then go to "Personal access tokens".
It is the icon to the left of your user icon, in the top right corner.

Then, create a new token, give it a name, make sure it expires quickly,
and give it a custom defined scope that includes the
"Agent pools: Read & manage" permission (you'll need to "Show all scopes"
to access this).
You can now copy this token and use it to allow machines to join.
