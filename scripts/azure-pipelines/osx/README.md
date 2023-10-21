# `vcpkg-eg-mac` VMs

## Table of Contents

- [`vcpkg-eg-mac` VMs](#vcpkg-eg-mac-vms)
  - [Table of Contents](#table-of-contents)
  - [Basic Usage](#basic-usage)
    - [Creating a new Vagrant box](#creating-a-new-vagrant-box)
      - [VM Software Versions](#vm-software-versions)
    - [Running the VM](#running-the-vm)
  - [Getting an Azure Pipelines PAT](#getting-an-azure-pipelines-pat)

## Basic Usage

The most common operation here is to set up a new VM for Azure
pipelines; we try to make that operation as easy as possible.
It should take all of three steps, assuming the machine is
already set up (or read [these instructions] for how to set up a machine):

1. [Create a new vagrant box](#creating-a-new-vagrant-box)
1. [Create a new agent pool](#creating-a-new-azure-agent-pool)
1. [Setup and run the vagrant VM](#running-the-vm)
1. Update `azure-pipelines.yml` and `azure-pipelines-osx.yml` to point to the new macOS pool.

[these instructions]: #setting-up-a-new-macos-machine

### Creating a new Vagrant box

Whenever we want to install updated versions of the command line tools,
or of macOS, we need to create a new vagrant box.
This is pretty easy, but the results of the creation are not public,
since we're concerned about licensing.
However, if you're sure you're following Apple's licensing,
you can set up your own vagrant boxes that are the same as ours by doing the following:

You'll need some prerequisites:

- [ ] A Parallels license
- [ ] An Xcode installer - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>

If you are doing this from a local macos box, you can skip to the "update the macos host" step.

- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues , pick the current osx queue,
      and delete one of the agents that are idle.
- [ ] Go to that machine in the KVM. (Passwords are stored as secrets in the CPP_GITHUB\vcpkg\vcpkgmm-passwords key vault)
- [ ] Open a terminal, and run:

      ```sh
      $ cd ~/vagrant
      $ vagrant destroy
      $ vagrant box list # note what the name of the box is
      $ vagrant box remove vcpkg-macos-2023-09-11
      ```

- [ ] Update the macos host
- [ ] Update or install parallels
- [ ] If this is the first time this machine has been used, install Homebrew by running:
    ```sh
    $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    $ brew install hashicorp/tap/hashicorp-vagrant
    $ vagrant plugin install vagrant-parallels
    ```

  otherwise, update homebrew by running:

    ```sh
    $ brew update
    $ brew upgrade
    ```

- [ ] Run parallels, and select 'Other Options' -> 'Install macOS 14.0 Using the Recovery Partition' (version number to change :))
- [ ] Install MacOS like you would on real hardware.
    * Apple ID: 'Set Up Later' / Skip
    * Account name: vagrant
    * Account password: vagrant
- [ ] Install Parallels Tools
- [ ] Shut down the VM
- [ ] Open Parallels Control Center, right click the VM, and make the following edits:
    * 12 processors
    * 24000 MB of memory
- [ ] Restart the VM
- [ ] Turn on the SSH server in the VM by opening system preferences, going to Sharing > Remote Login, and turning it on.
- [ ] Add the vagrant SSH keys to the VM's vagrant user, by opening a terminal and running the following:

    ```sh
    $ # basic stuff
    $ date | sudo tee '/etc/vagrant_box_build_time'
    $ printf 'vagrant\tALL=(ALL)\tNOPASSWD:\tALL\n' | sudo tee -a '/etc/sudoers.d/vagrant'
    $ sudo chmod 0440 '/etc/sudoers.d/vagrant'
    $ # then install vagrant keys
    $ mkdir -p ~/.ssh
    $ curl -fsSL 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' >~/.ssh/authorized_keys
    $ chmod 0600 ~/.ssh/authorized_keys
    ```

- [ ] Shut down the VM cleanly.
- [ ] On the host, open the terminal and run the following to package the VM into a base box. Name the box after the version of macOS in question, such as macos-14-0.box. (The following instructions are adapted from
[these official instructions][base-box-instructions]).

    ```sh
    $ cd ~/Parallels
    $ echo '{ "provider": "parallels" }' >metadata.json
    $ prl_disk_tool compact --hdd ./<name of VM>.pvm/harddisk.hdd
    $ tar zcvf <name-of-box>.box ./metadata.json ./<name of VM>.pvm
    $ rm ./metadata.json
    ```

- [ ] Delete the VM in Parallels and make sure the original .pvm directory is gone.
- [ ] Add the base box to Vagrant by running the following. `<name-of-customized-box>` should be macos-YYYY-MM-DD.

    ```sh
    $ vagrant box add <name-of-box>.box --name <name-of-box>
    $ rm <name-of-box>.box
    $ mkdir -p ~/<name-of-customized-box>
    ```

- [ ] In `Vagrantfile-box.rb`, the config.vm.box line to <name-of-box>.
- [ ] Copy `Vagrantfile-box.rb` as `Vagrantfile` into ~/<name-of-customized-box>. For instance, from your local machine you can do

    ```console
    $ scp Vagrantfile-box.rb vcpkg@<DNS of the machine>:/Users/vcpkg/<name-of-customized-box>/Vagrantfile
    ```

- [ ] Copy the XCode command line tools DMG you want to use, typically from
https://developer.apple.com/download/all/ , and name it `clt.dmg`.
For instance, from your local machine you can do

    ```console
    scp Command_Line_Tools_for_Xcode_15.dmg vcpkg@<DNS of the machine>:/Users/vcpkg/<name-of-customized-box>/clt.dmg
    ```

- [ ] Go back to the macOS machine, and run the following to create the box:

    ```sh
    $ vagrant up
    $ vagrant package
    $ vagrant destroy
    $ vagrant box remove <name-of-box>
    ```

- [ ] If this machine is also borrowed from the pool add the resulting customized .box back. If so, skip the `vagrant box add` parts of the steps when running the "Running the VM" steps on this machine.

    ```sh
    $ vagrant box add ./package.box --name <name-of-customized-box>
    ```

- [ ] Copy `package.box` to locally. Name it based on the current date, such as `macos-2023-10-20.box`

    ```console
    scp vcpkg@<DNS of the machine>:/Users/vcpkg/<name-of-customized-box>/package.box <name-of-customized-box>.box
    ```

- [ ] Delete the temporary directory:

    ```sh
    $ rm --rf ~/<name-of-customized-box>
    ```

- [ ] Log in to the Azure Portal, and upload the box to
vcpkg-image-minting/vcpkg-image-minting/boxes.
- [ ] Change the N-2th box to the 'Archive' tier, and the the N-1th box to the 'Cool' tier.
- [ ] Generate a SAS'd link to the new box to use in the "Running the VM" steps below.
- [ ] Update the software versions under [VM Software Versions](#vm-software-versions) below
- [ ] Go to https://dev.azure.com/vcpkg/public/_settings/agentqueues and create a new self hosted Agent pool named `PrOsx-YYYY-MM-DD` based on the current date. Check 'Grant access permission to all pipelines.'
- [ ] Get the current Agent version by pressing 'New Agent', and update Vagrantfile-vm.rb with this version number.
- [ ] Update Vagrantfile-vm.rb with the right dates for the box and pool.
- [ ] Update azure-pipelines.yml with the new pool, and commit all of this.
- [ ] Follow the "Running the VM" steps below for each machine in the fleet.

[base-box-instructions]: https://parallels.github.io/vagrant-parallels/docs/boxes/base.html

#### VM Software Versions

* macOS: 14.0
* Xcode CLTs: 15.0

### Running the VM

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
    ```

- [ ] Check for software updates in macOS system settings
- [ ] Check for software updates in Parallels' UI
- [ ] Update homebrew dependencies

    ```sh
    $ brew update
    $ brew upgrade
    ```

- [ ] Mint a SAS token URI to the box to use from the Azure portal if you don't already have one, and pull the box. <name-of-customized-box> should be macos-YYYY-MM-DD.

    ```sh
    $ vagrant box add '<SAS URI>' --name <name-of-customized-box>
    ```

- [ ] [grab a PAT], and update the contents of `Vagrantfile-vm.rb`. DO NOT COMMIT THIS EDIT.
- [ ] Update the machine name in `Vagrantfile-vm.rb`
- [ ] Copy Vagrantfile-vm.rb as `~/vagrant/Vagrantfile`

    ```console
    $ scp Vagrantfile-vm.rb vcpkg@<DNS of the machine>:/Users/vcpkg/vagrant/Vagrantfile
    ```

- [ ] Back on the macOS machine, fire up the VM:

    ```sh
    $ cd ~/vagrant
    $ vagrant up
    ```

  If the `vagrant up` fails you might need to `vagrant halt` and rerun from within the KVM as sometimes over SSH this fails.

- [ ] Check that the machine shows up in the pool, and log out of the vcpkg user.
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
