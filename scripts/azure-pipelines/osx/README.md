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
  - [Troubleshooting](#troubleshooting)
  - [(Internal) Accessing the macOS fileshare](#internal-accessing-the-macos-fileshare)

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
- The software installed by `Install-Prerequisites.ps1`

If you're updating the CI pool, make sure you update macOS.

First, you'll need to create a base VM;
this is where you determine what version of macOS is installed.
Follow the Parallels process for creating a macOS VM; this involves
updating to whatever version, and then scrolling right until you find
"Install macOS from recovery partition".

Once you've done this, you can run through the installation of macOS onto a new VM.
You should set the username to `vagrant`.

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

Finally, you'll need to install the Parallel Tools.
From your host, in the top bar,
go to Actions > Install Parallels Tools...,
and then follow the instructions.

Now, let's package the VM into a base box.
(The following instructions are adapted from
[these official instructions][base-box-instructions]).

Run the following commands:

```sh
$ cd ~/Parallels
$ echo '{ "provider": "parallels" }' >metadata.json
$ tar zcvf <macos version>.box ./metadata.json ./<name of VM>.pvm
```

This will create a box file which contains all the necessary data.
You can delete the `metadata.json` file after.

Once you've done that, you can upload it to the fileshare,
under `share/boxes/macos-base`, add it to `share/boxes/macos-base.json`,
and finally add it to vagrant:

```sh
$ vagrant box add ~/vagrant/share/boxes/macos-base.json
```

Then, we'll create the final box,
which contains all the necessary programs for doing CI work.
Copy `configuration/Vagrantfile-box.rb` as `Vagrantfile`, and
`configuration/vagrant-box-configuration.json`
into a new directory; into that same directory,
download the Xcode command line tools dmg, and name it `clt.dmg`.
Then, run the following in that directory:

```sh
$ vagrant up
$ vagrant package
```

This will create a `package.box`, which is the box file for the base VM.
Once you've created this box, if you're making it the new box for the CI,
upload it to the fileshare, under `share/boxes/macos-ci`.
Then, add the metadata about the box (the name and version) to
`share/boxes/macos-ci.json`.
Once you've done that, add the software versions under [VM Software Versions](#vm-software-versions).

[base-box-instructions]: https://parallels.github.io/vagrant-parallels/docs/boxes/base.html

#### VM Software Versions

* 2022-02-04 (minor update to 2022-01-03)
  * macOS: 12.1
  * Xcode CLTs: 13.2
* 2022-01-03:
  * macOS: 12.1
  * Xcode CLTs: 13.2
* 2021-07-27:
  * macOS: 11.5.1
  * Xcode CLTs: 12.5.1
* 2021-04-16:
  * macOS: 11.2.3
  * Xcode CLTs: 12.4
* 2020-09-28:
  * macOS: 10.15.6
  * Xcode CLTs: 12

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

First, make sure that your software is up to date:
```sh
$ cd ~/vcpkg
$ git fetch
$ git switch -d origin/master
$ ./scripts/azure-pipelines/osx/Install-Prerequisites.ps1
```

as well as checking to make sure macOS is up to date.

Then, follow the instructions for [accessing ~/vagrant/share][access-fileshare].

And finally, [grab a PAT], update the vagrant box, set up the VM, and run it:
```sh
$ vagrant box remove -f vcpkg/macos-ci # This won't do anything if the machine never had a box before
$ vagrant box add ~/vagrant/share/boxes/macos-ci.json
$ ~/vcpkg/scripts/azure-pipelines/osx/Setup-VagrantMachines.ps1 -Date <box version YYYY-MM-DD> -DevopsPat <PAT>
$ cd ~/vagrant/vcpkg-eg-mac
$ vagrant up # if this fails, reboot through the kvm and/or log in interactively, then come back here
```

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

Before anything else, one must download `brew` and `powershell`.

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
$ brew cask install powershell
```

Then, we need to download the `vcpkg` repository:

```sh
$ git clone https://github.com/microsoft/vcpkg
```

Then, we need to mint an SSH key:

```sh
$ ssh-keygen
$ cat .ssh/id_rsa.pub
```

Add that SSH key to `authorized_keys` on the file share machine with the base box.

Next, install prerequisites:
```sh
$ cd vcpkg/scripts/azure-pipelines/osx
$ ./Install-Prerequisites.ps1 -Force
```

And finally, make sure you can [access ~/vagrant/share][access-fileshare].

## Troubleshooting

The following are issues that we've run into:

- (with a Parallels box) `vagrant up` doesn't work, and vagrant gives the error that the VM is `'stopped'`.
  - Try logging into the GUI with the KVM, and retrying `vagrant up`.
- (when running a powershell script) The error `Failed to initialize CoreCLR, HRESULT: 0x8007001F` is printed.
  - Reboot the machine; run
  ```sh
  $ sudo shutdown -r now
  ```
  and wait for the machine to start back up. Then, start again from where the error was emitted.

## (Internal) Accessing the macOS fileshare

The fileshare is located on `vcpkgmm-01`, under the `fileshare` user, in the `share` directory.
In order to get `sshfs` working on the physical machine,
You can run `Install-Prerequisites.ps1` to grab the right software, then either:

```sh
$ mkdir -p ~/vagrant/share
$ sshfs fileshare@vcpkgmm-01:share ~/vagrant/share
```

If you get an error, that means that gatekeeper has prevented the kernel extension from loading,
so you'll need to access the GUI of the machine, go to System Preferences,
Security & Privacy, General, unlock the settings,
and allow system extensions from the osxfuse developer to run.
Then, you'll be able to add ~/vagrant/share as an sshfs.

[access-fileshare]: #internal-accessing-the-macos-fileshare
