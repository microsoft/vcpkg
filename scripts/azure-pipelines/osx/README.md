# `vcpkg-eg-mac` VMs

## Table of Contents

- [`vcpkg-eg-mac` VMs](#vcpkg-eg-mac-vms)
  - [Table of Contents](#table-of-contents)
  - [Basic Usage](#basic-usage)
    - [Creating a new Vagrant box](#creating-a-new-vagrant-box)
      - [VM Software Versions](#vm-software-versions)
    - [Creating a New Azure Agent Pool](#creating-a-new-azure-agent-pool)
    - [Running the VM](#running-the-vm)
  - [Getting an Azure Pipelines PAT](#getting-an-azure-pipelines-pat)
  - [Setting up a new macOS machine](#setting-up-a-new-macos-machine)

## Basic Usage

The most common operation here is to set up a new VM for Azure
pipelines; we try to make that operation as easy as possible.
It should take all of three steps, assuming the machine is
already set up (or read [these instructions] for how to set up a machine):

1. [Create a new vagrant box](#creating-a-new-vagrant-box)
2. [Create a new agent pool](#creating-a-new-azure-agent-pool)
3. [Setup and run the vagrant VM](#running-the-vm)
4. Update `azure-pipelines.yml` and `azure-pipelines-osx.yml` to point to the new macOS pool.

[these instructions]: #setting-up-a-new-macos-machine

### Creating a new Vagrant box

Whenever we want to install updated versions of the command line tools,
or of macOS, we need to create a new vagrant box.
This is pretty easy, but the results of the creation are not public,
since we're concerned about licensing.
However, if you're sure you're following Apple's licensing,
you can set up your own vagrant boxes that are the same as ours by doing the following:

You'll need some prerequisites:

- An Xcode installer - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>

If you're updating the CI pool, make sure you update macOS.

First, you'll need to create a base VM;
this is where you determine what version of macOS is installed.
Follow the Parallels process for creating a macOS VM:

1. Get a machine with matching version of Parallels.
2. If you haven't already, install Vagrant and vagrant-parallels:
      ```sh
      $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
      $ brew install hashicorp/tap/hashicorp-vagrant
      $ vagrant plugin install vagrant-parallels
      ```
3. Update your MacOS host.
4. Run parallels, and select 'Other Options' -> 'Install macOS 13.5.2 Using the Recovery Partition' (version number to change :))
5. Install MacOS like you would on real hardware.
    * Apple ID: 'Set Up Later' / Skip
    * Account name: vagrant
    * Account password: vagrant
6. Install Parallels Tools
7. Shut down the VM
8. Open Parallels Control Center, right click the VM, and make the following edits:
    * 12 processors
    * 24000 MB of memory

Once it's finished installing, make sure to turn on the SSH server.
Open System Preferences, then go to Sharing > Remote Login,
and turn it on.
You'll then want to add the vagrant SSH keys to the VM's vagrant user.
Open the terminal application and run the following:

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

Now, let's package the VM into a base box.
(The following instructions are adapted from
[these official instructions][base-box-instructions]).

Shut down the VM cleanly. On the host, run the following commands:

```sh
$ cd ~/Parallels
$ echo '{ "provider": "parallels" }' >metadata.json
$ prl_disk_tool compact --hdd ./<name of VM>.pvm/harddisk.hdd
$ tar zcvf <name-of-box>.box ./metadata.json ./<name of VM>.pvm
$ rm ./metadata.json
```

This will create a box file which contains all the necessary data.

```sh
$ vagrant box add <name-of-box>.box --name <name-of-box>
```

Then, we'll create the final box,
which contains all the necessary programs for doing CI work.
Copy `Vagrantfile-box.rb` as `Vagrantfile`
into a new directory. Edit the config.vm.box line to <name-of-box>.
Into that same directory, download the Xcode command line tools dmg, typically from
https://developer.apple.com/download/all/ , and name it `clt.dmg`.
Then, run the following in that directory:

```sh
$ vagrant up
$ vagrant package
$ vagrant destroy
```

This will create a `package.box`, which is the box file for the base VM.
Once you've created this box, log in to the Azure Portal, and upload the box to
vcpkg-image-minting/vcpkgvagrantboxes/boxes. (You might need to use scp to copy the box to
a machine that can see the Portal)

Once you've done that, add the software versions under [VM Software Versions](#vm-software-versions).

[base-box-instructions]: https://parallels.github.io/vagrant-parallels/docs/boxes/base.html

#### VM Software Versions

* 2023-09-11
  * macOS: 13.5
  * Xcode CLTs: 14.3.1
* 2022-02-04 (minor update to 2022-01-03)
  * macOS: 12.1
  * Xcode CLTs: 13.2

### Creating a New Azure Agent Pool

When updating the macOS machines to a new version, you'll need to create
a new agent pool for the machines to join. The standard for this is to
name it `PrOsx-YYYY-MM-DD`, with `YYYY-MM-DD` the day that the process
is started.

In order to create a new agent pool, go to the `vcpkg/public` project;
go to `Project settings`, then go to `Agent pools` under `Pipelines`.
Add a new self-hosted pool, name it as above, and make certain to check
the box for "Grant access permission to all pipelines".

Once you've done this, you are done; you can start adding new machines
to the pool!

### Running the VM

First, make sure that your software is up to date, first by checking in

* macOS system settings
* Parallels' UI
* homebrew:
    ```sh
    $ brew update
    $ brew upgrade
    ```

If this machine has been used before, you might have to remove an existing boxes:

```sh
$ cd ~/vagrant/vcpkg-ec-mac
$ vagrant halt
$ vagrant destroy
$ cd ~
$ rm -rf ~/vagrant
$ mkdir ~/vagrant
```

[grab a PAT], mint a SAS token to vcpkg-image-minting/vcpkgvagrantboxes/boxes, and pull the box:

```sh
$ vagrant box list
$ vagrant box remove <any boxes listed by previous command>
$ vagrant box add 'https://vcpkgvagrantboxes.blob.core.windows.net/boxes/<name of box>.box?<SAS token>' --name <name of box>
```

Copy the contents of Vagrantfile-vm.rb to ~/vagrant/Vagrantfile, and edit the values at the top
to match this particular machine:

* machine_name
* box
* azure_agent_url should be changed to the latest version
* agent_pool
* pat

Then:

```sh
$ cd ~/vagrant
$ vagrant up
```

If the `vagrant up` fails you might need to `vagrant halt` and rerun from within the KVM as
sometimes over SSH this fails.

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

## Setting up a new macOS machine

* Install Parallels
* Install Homebrew
    ```sh
    $ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    $ brew install hashicorp/tap/hashicorp-vagrant
    $ vagrant plugin install vagrant-parallels
    ```
