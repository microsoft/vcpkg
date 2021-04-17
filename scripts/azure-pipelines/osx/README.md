# `vcpkg-eg-mac` VMs

## Table of Contents

- [`vcpkg-eg-mac` VMs](#vcpkg-eg-mac-vms)
  - [Table of Contents](#table-of-contents)
  - [Basic Usage](#basic-usage)
  - [Setting up a new macOS machine](#setting-up-a-new-macos-machine)

## Basic Usage

The simplest usage, and one which should be used for when spinning up
new VMs, and when restarting old ones, is a simple:

```
$ cd ~/vagrant/vcpkg-eg-mac
$ vagrant up
```

Any modifications to the machines should be made in `configuration/Vagrantfile`
and `Setup-VagrantMachines.ps1`, and make sure to push any changes!

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

Next, install prerequisites and grab the current base box with:
```sh
$ cd vcpkg/scripts/azure-pipelines/osx
$ ./Install-Prerequisites.ps1 -Force
$ ./Get-InternalBaseBox.ps1 -FileshareMachine vcpkgmm-01.guest.corp.microsoft.com -BoxVersion 2020-09-28
```

... where -BoxVersion is the version you want to use.

Getting the base box will fail due to missing kernel modules for osxfuse, sshfs, and/or VirtualBox.
Log in to the machine, open System Preferences > Security & Privacy > General, and allow the kernel
extensions for VirtualBox and sshfs to load. Then, again:

```sh
$ ./Get-InternalBaseBox.ps1 -FileshareMachine vcpkgmm-01.guest.corp.microsoft.com -BoxVersion 2020-09-28
```

Replace `XX` with the number of
the virtual machine. Generally, that should be the same as the number
for the physical machine; i.e., vcpkgmm-04 would use 04.

```sh
  # NOTE: you may get an error about CoreCLR; see the following paragraph if you do
$ ./Setup-VagrantMachines.ps1 \
  -MachineId XX \
  -DevopsPat '<get this from azure devops; it needs agent pool read and manage access>' \
  -Date <this is the date of the pool; 2020-09-28 at time of writing>
$ cd ~/vagrant/vcpkg-eg-mac
$ vagrant up
```

If you see the following error:

```
Failed to initialize CoreCLR, HRESULT: 0x8007001F
```

You have to reboot the machine; run

```sh
$ sudo shutdown -r now
```

and wait for the machine to start back up. Then, start again from where the error was emitted.

## Creating a new Vagrant box

Whenever we want to install updated versions of the command line tools,
or of macOS, we need to create a new vagrant box.
This is pretty easy, but the results of the creation are not public,
since we're concerned about licensing.
However, if you're sure you're following Apple's licensing,
you can set up your own vagrant boxes that are the same as ours by doing the following:

You'll need some prerequisites:

- vagrant - found at <https://www.vagrantup.com/>
	- The vagrant-scp plugin - just run `vagrant plugin install vagrant-scp`
- Parallels - found at <https://parallels.com>
- An Xcode installer - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>

First, you'll need to create a base VM;
this is where you determine what version of macOS is installed.
Just follow the Parallels process for creating a macOS VM.

Once you've done this, you can run through the installation of macOS onto a new VM.
We recommend having more than one CPU core (we use 6).
You should set the username to `vagrant`.

Once it's finished installing, make sure to turn on the SSH server.
Open System Preferences, then go to Sharing > Remote Login,
and turn it on.
You'll then want to add the vagrant SSH keys to the VM's vagrant user.
Open the terminal application and run the following:

```sh
$ # basic stuff
$ sudo sh -c "date >/etc/vagrant_box_build_time"
$ sudo sh -c 'printf "vagrant\tALL=(ALL)\tNOPASSWD:\tALL\n" >>/etc/sudoers.d/vagrant'
$ sudo chmod 0440 /etc/sudoers.d/vagrant
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
Turn it off, and follow [these instructions][base-box-instructions]
to create a base box.
The Vagrantfile inside the base box should contain the following:

```rb
Vagrant.configure('2') do |config|
	config.vm.box_check_update = false
	config.vm.network :forwarded_port, guest: 22, host: 2222, id: 'ssh', disabled: true
	config.vm.synced_folder '.', '/vagrant', disabled: true
end
```

Once you've done that, you can add it to vagrant:

```sh
$ vagrant box add ./custom.box --name "macos-ci-base"
```

Then, to create the final box, we'll need to do the rest with vagrant.
Create a `Vagrantfile` that looks like the following:

```rb
Vagrant.configure('2') do |config|
	config.vm.box = 'macos-ci-base'
	config.vm.boot_timeout = 600
	config.vm.synced_folder ".", "/vagrant", disabled: true
end
```

then, run the following in that vagrant directory:

```sh
$ vagrant up
$ vagrant scp <path to Command Line Tools for Xcode installer> :clt.dmg
$ vagrant ssh -c 'hdiutil attach clt.dmg -mountpoint /Volumes/setup-installer'
$ vagrant ssh -c 'sudo installer -pkg "/Volumes/setup-installer/Command Line Tools.pkg" -target /'
$ vagrant ssh -c 'hdiutil detach /Volumes/setup-installer'
$ vagrant ssh -c 'rm clt.dmg'
$ vagrant ssh -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
$ vagrant reload
```

if that works, you can now package the box:

```sh
$ vagrant package
```

This will create a `package.box`, which is the box file for the base VM.
Then, you can `vagrant box add <package.box> --name <name for the box>`,
and you'll have the base vcpkg box added for purposes of `Setup-VagrantMachines.ps1`!

Once you've created the base box, if you're making it the new base box for the CI,
upload it to the fileshare, under `share/vcpkg-boxes`.
Then, add the metadata about the box (the name and version) to the JSON file there.
Once you've done that, add the software versions under [VM Software Versions](#vm-software-versions).

[base-box-instructions]: https://parallels.github.io/vagrant-parallels/docs/boxes/base.html

### VM Software Versions

* 2020-09-28:
  * macOS: 10.15.6
  * Xcode CLTs: 12
* 2021-04-16:
	* macOS: 11.2.3
	* Xcode CLTs: 12.4

### (Internal) Accessing the macOS fileshare

The fileshare is located on `vcpkgmm-01`, under the `fileshare` user, in the `share` directory.
In order to get `sshfs` working on the physical machine,
You can run `Install-Prerequisites.ps1` to grab the right software, then either:

```sh
$ mkdir vagrant/share
$ sshfs fileshare@<vcpkgmm-01 URN>:/Users/fileshare/share vagrant/share
```

or you can just run

```sh
$ ./Get-InternalBaseBox.ps1
```

which will do the thing automatically.

If you get an error, that means that gatekeeper has prevented the kernel extension from loading,
so you'll need to access the GUI of the machine, go to System Preferences,
Security & Privacy, General, unlock the settings,
and allow system extensions from the osxfuse developer to run.
Then, you'll be able to add the fileshare as an sshfs.
