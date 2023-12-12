# `vcpkg-eg-mac` VMs

This is the checklist for what the vcpkg team does when updating the macOS machines in the pool.

## Creating new base images

### Prerequisites

- [ ] A Parallels license
- [ ] An Xcode installer - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>  
  If you are doing this from a local macos box, you can skip to the "update the macos host" step.  
  If copying from a local box to one of the macOS machines, you can use scp:
    ```sh
    scp Command_Line_Tools_for_Xcode_15.dmg vcpkg@<DNS of the machine>:/Users/vcpkg/clt.dmg
    ```

### Instructions (AMD64)

- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues , pick the current osx queue,
      and delete one of the agents that are idle.
- [ ] Go to that machine in the KVM. (Passwords are stored as secrets in the CPP_GITHUB\vcpkg\vcpkgmm-passwords key vault)
- [ ] Open a terminal and destroy any old vagrant VMs or boxes
    ```sh
    cd ~/vagrant
    vagrant halt
    vagrant destroy
    vagrant box list
    vagrant box remove <any boxes listed by previous command>
    brew remove hashicorp-vagrant
    ```
- [ ] Open the Parallels Control Center, and delete the active VM.
- [ ] Update the macos host
- [ ] Update or install parallels
- [ ] Download the macOS installer from the app store. See https://support.apple.com/en-us/102662  
      Note: This portion of the instructions is that which breaks most often depending on what Parallels and macOS are doing.
      You might need to use `softwareupdate --fetch-full-installer --full-installer-version 14.2` and point Parallels
      at that resulting installer in 'Applications' instead.
- [ ] Run parallels, and select that installer you just downloaded. Name the VM "vcpkg-osx-<DATE>-amd64", for example "vcpkg-osx-2024-01-18-amd64".
- [ ] When creating the VM, customize the hardware to the following:
    * 12 processors
    * 24000 MB of memory
    * 350 GB disk
    * Do not share mac camera
- [ ] Install MacOS like you would on real hardware.
    * Apple ID: 'Set Up Later' / Skip
    * Account name: vcpkg
    * Account password: vcpkg
- [ ] Install Parallels Tools
- [ ] Restart the VM
- [ ] Change the desktop background to a solid color
- [ ] Enable remote login in System Settings -> General -> Sharing -> Remote Login
- [ ] Shut down the VM cleanly
- [ ] Set the VM 'Isolated'
- [ ] Update the Azure Agent URI in setup-box.sh to the current version. You can find this by going to the agent pool, selecting "New agent", picking macOS, and copying the link. For example https://vstsagentpackage.azureedge.net/agent/3.232.0/vsts-agent-osx-x64-3.232.0.tar.gz
- [ ] In the guest, set the vcpkg user to be able to use sudo without a password:
    ```sh
    printf 'vcpkg\tALL=(ALL)\tNOPASSWD:\tALL\n' | sudo tee -a '/etc/sudoers.d/vcpkg'
    sudo chmod 0440 '/etc/sudoers.d/vcpkg'
    ```
- [ ] Copy setup-guest, setup-box.sh, and the xcode installer renamed to 'clt.dmg' to the host, and run setup-guest.sh. For example:
    ```sh
    scp ./setup-guest.sh vcpkg@MACHINE:/Users/vcpkg/Downloads
    scp ./setup-box.sh vcpkg@MACHINE:/Users/vcpkg/Downloads
    scp path/to/console/tools.dmg vcpkg@MACHINE:/Users/vcpkg/Downloads/clt.dmg
    ssh vcpkg@MACHINE
    cd /Users/vcpkg/Downloads
    chmod +x ./setup-guest.sh
    ./setup-guest.sh
    exit
    ```
- [ ] Shut down the VM cleanly.
- [ ] In Parallels control center, right click the VM and select "Prepare for Transfer"
- [ ] In Parallels control center, right click the VM and remove it, but "Keep Files"
- [ ] Copy the packaged VM to Azure Storage, with something like:
    ```sh
    ssh vcpkg@MACHINE
    brew install azcopy
    azcopy copy ~/Parallels/vcpkg-macos-2024-01-18-amd64.pvmp "https://vcpkgimageminting...../pvms?<SAS>"
    azcopy copy ~/Parallels/vcpkg-macos-2024-01-18-amd64.sha256.txt "https://vcpkgimageminting...../pvms?<SAS>"
    ```
- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues and create a new self hosted Agent pool named `PrOsx-YYYY-MM-DD` based on the current date. Check 'Grant access permission to all pipelines.'
- [ ] Remove the macOS installer from Applications
- [ ] Follow the "Deploying images" steps below for each machine in the fleet.

### Instructions (ARM64)

- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues , pick the current osx queue,
      and delete one of the agents that are idle.
- [ ] Go to that machine in the KVM. (Passwords are stored as secrets in the CPP_GITHUB\vcpkg\vcpkgmm-passwords key vault)
- [ ] Open the Parallels Control Center, and delete the active VM.
- [ ] Update the macos host
- [ ] Update or install parallels
- [ ] Download the matching `.ipsw` for the macOS copy to install. See https://kb.parallels.com/en/125561 ; links there to find the .ipsw. Example: https://updates.cdn-apple.com/2023FallFCS/fullrestores/052-09443/E8752548-0B80-480C-9FB4-67246672C1B5/UniversalMac_14.1.2_23B92_Restore.ipsw
- [ ] Determine the VM name using the form "vcpkg-osx-<date>-arm64", for example "vcpkg-osx-2024-01-18-arm64".
- [ ] Open a terminal and run the following commands to create the VM.
    ```sh
    prlctl create "vcpkg-osx-<date>-arm64" -o macos --restore-image ~/Downloads/path/to.ipsw
    prlctl set "vcpkg-osx-<date>-arm64" --memsize 12288 --cpus 8 --isolate-vm on --shf-host-defined off
    cd ~/Parallels/vcpkg-osx-<date>-arm64.macvm
    truncate -s 500G disk0.img
    ```
- [ ] Start the VM in parallels and follow prompts as you would on real hardware.
    * Apple ID: 'Set Up Later' / Skip
    * Account name: vcpkg
    * Account password: vcpkg
- [ ] Set the desktop wallpaper to a fixed color from Settings -> Wallpaper . (This makes the KVM a lot easier to use :) )
- [ ] Update the Azure Agent URI in setup-box.sh to the current version. You can find this by going to the agent pool, selecting "New agent", picking macOS, and copying the link. For example https://vstsagentpackage.azureedge.net/agent/3.232.1/vsts-agent-osx-arm64-3.232.1.tar.gz
- [ ] Enable remote login in the VM: Settings -> General -> Sharing -> Remote Login
- [ ] In the guest, set the vcpkg user to be able to use sudo without a password:
    ```sh
    printf 'vcpkg\tALL=(ALL)\tNOPASSWD:\tALL\n' | sudo tee -a '/etc/sudoers.d/vcpkg'
    sudo chmod 0440 '/etc/sudoers.d/vcpkg'
    ```
- [ ] Copy setup-box.sh and the xcode installer renamed to 'clt.dmg' to the host. For example:
    ```sh
    scp ./setup-guest.sh vcpkg@MACHINE:/Users/vcpkg/Downloads
    scp ./setup-box.sh vcpkg@MACHINE:/Users/vcpkg/Downloads
    scp path/to/console/tools.dmg vcpkg@MACHINE:/Users/vcpkg/Downloads/clt.dmg
    ssh vcpkg@MACHINE chmod +x /Users/vcpkg/Downloads/setup-guest.sh
    ssh vcpkg@MACHINE /Users/vcpkg/Downloads/setup-guest.sh
    ```
- [ ] Shut down the VM cleanly.
- [ ] Remove the VM in Parallels Control Center, and 'Keep Files'
- [ ] Mint a SAS token to vcpkgimageminting/pvms with read, add, create, write, and list permissions.
- [ ] Open a terminal on the host and package the VM into a tarball:
    ```sh
    cd ~/Parallels
    tar czf vcpkg-osx-<date>-arm64.macvm.tar.gz vcpkg-osx-<date>-arm64.macvm
    brew install azcopy
    azcopy copy vcpkg-osx-<date>-arm64.macvm.tar.gz "https://vcpkgimageminting.blob.core.windows.net/pvms?<SAS>"
    ```
- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues and create a new self hosted Agent pool named `PrOsx-YYYY-MM-DD-arm64` based on the current date. Check 'Grant access permission to all pipelines.'
- [ ] Follow the "Deploying images" steps below for each machine in the fleet.

## Deploying images

### Running the VM (AMD64)

Run these steps on each machine to add to the fleet. Skip steps that were done implicitly above if this machine was used to build a box.

- [ ] If this machine was used before, delete it from the pool of which it is a member from https://dev.azure.com/vcpkg/public/_settings/agentqueues
- [ ] Log in to the machine using the KVM.
- [ ] Open a terminal and destroy any old vagrant VMs or boxes
    ```sh
    $ cd ~/vagrant
    $ vagrant halt
    $ vagrant destroy
    $ vagrant box list
    $ vagrant box remove <any boxes listed by previous command except the one to use>
    $ brew remove hashicorp-vagrant
    ```
- [ ] Check for software updates in macOS system settings
- [ ] Check for software updates in Parallels' UI
- [ ] Mint a SAS token URI to the box to use from the Azure portal if you don't already have one, and download the VM. (Recommend running this via SSH from domain joined machine due to containing SAS tokens)
    ```sh
    brew install azcopy
    cd ~/Parallels
    azcopy copy "https://vcpkgimageminting.blob.core.windows.net/pvms/vcpkg-osx-<DATE>-amd64.pvmp?<SAS>" .
    azcopy copy "https://vcpkgimageminting.blob.core.windows.net/pvms/vcpkg-osx-<DATE>-amd64.sha256.txt?<SAS>" .
    ```
- [ ] Open the .pvmp in Parallels, and unpack it.
- [ ] Start the VM
- [ ] [grab a PAT][] if you don't already have one
- [ ] Copy the guest deploy script to the host, and run it with a first parameter of your PAT
    ```sh
    scp ./register-guest.sh vcpkg@MACHINE:/Users/vcpkg
    ssh vcpkg@MACHINE
    chmod +x /Users/vcpkg/register-guest.sh
    /Users/vcpkg/register-guest.sh <PAT>
    ```
- [ ] Open a terminal window on the host and run the agent
    ```
    ssh -i ~/Parallels/*/id_guest -o StrictHostKeychecking=no vcpkg@`prlctl list --full | sed -nr 's/^.*running *([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`
    ~/myagent/run.sh
    ```
- [ ] Check that the machine shows up in the pool, and lock the vcpkg user on the host.
- [ ] Lock the screen on the host.
- [ ] Update the "vcpkg Macs" spreadsheet line for the machine with the new pool.

[grab a PAT]: #getting-an-azure-pipelines-pat

### Running the VM (ARM64)

Run these steps on each machine to add to the fleet. Skip steps that were done implicitly above if this machine was used to build a box.

- [ ] If this machine was used before, delete it from the pool of which it is a member from https://dev.azure.com/vcpkg/public/_settings/agentqueues
- [ ] Log in to the machine using the KVM.
- [ ] Check for software updates in macOS system settings
- [ ] Check for software updates in Parallels' UI
- [ ] Skip if this is the image building machine. Mint a SAS token URI to the box to use from the Azure portal if you don't already have one, and download the VM. (Recommend running this via SSH from domain joined machine due to containing SAS tokens)
    ```sh
    cd ~/Parallels
    rm vcpkg-*.tar.gz
    azcopy copy "https://vcpkgimageminting.blob.core.windows.net/pvms/vcpkg-osx-<DATE>-arm64.macvm.tar.gz?<SAS>" vcpkg-osx-<DATE>-arm64.macvm.tar.gz
    tar xvf vcpkg-osx-<DATE>-arm64.macvm.tar.gz
    ```
- [ ] Open the .macvm in Parallels, and start it
- [ ] [grab a PAT][] if you don't already have one
- [ ] Copy the guest deploy script to the host, and run it with a first parameter of your PAT
    ```sh
    scp ./register-guest.sh vcpkg@MACHINE:/Users/vcpkg
    ssh vcpkg@MACHINE chmod +x /Users/vcpkg/register-guest.sh
    ssh vcpkg@MACHINE /Users/vcpkg/register-guest.sh <PAT>
    ```
- [ ] Open a terminal window on the host and run the agent
    ```sh
    ssh -i ~/Parallels/*/id_guest -o StrictHostKeychecking=no vcpkg@vcpkgs-Virtual-Machine.local
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
