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

Any modifications to the machines should be made in `configuration/VagrantFile`
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

And now all we need to do is set it up! Replace `XX` with the number of
the virtual machine. Generally, that should be the same as the number
for the physical machine; i.e., vcpkgmm-04 will have vcpkg-eg-mac-04.

```sh
$ cd vcpkg/scripts/azure-pipelines/osx
$ ./Install-Prerequisites.ps1 -Force
  # NOTE: you may get an error about CoreCLR; see the following paragraph if you do
$ ./Setup-VagrantMachines.ps1 XX \
  -Pat '<get this from azure>' \
  -ArchivesUsername '<get this from the archives share>' \
  -ArchivesAccessKey '<get this from the archives share>' \
  -ArchivesUrn '<something>.file.core.windows.net' \
  -ArchivesShare 'archives'
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

and wait for the machine to start back up. Then, start again from
`Install-Prerequisites.ps1`.

## Creating a new Vagrant box

Whenever we want to install updated versions of the command line tools,
or of macOS, we need to create a new vagrant box.
This is pretty easy, but the results of the creation are not public,
since we're concerned about licensing.
However, if you're sure you're following Apple's licensing,
you can set up your own vagrant boxes that are the same as ours by doing the following:

You'll need some prerequisites:

- macinbox - installable via `sudo gem install macinbox`
- vagrant - found at <https://www.vagrantup.com/>
- VirtualBox - found at <https://www.virtualbox.org/>
- A macOS installer application - you can get this from the App Store (although I believe only the latest is available)
- An Xcode Command Line Tools installer - you can get this from Apple's developer website,
  although you'll need to sign in first: <https://developer.apple.com/downloads>

First, you'll need to create a base box;
this is where you determine what version of macOS is installed.

```
> sudo macinbox \
  --box-format virtualbox \
  --name macos-ci-base \
  --installer <path to macOS installer> \
  --no-gui
```

Once you've done that, create a Vagrantfile that looks like the following:

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
$ vagrant ssh -c 'brew cask install osxfuse && brew install sshfs'
$ vagrant scp <path to ssh key for fileshare> :.ssh/id_rsa
$ vagrant scp <path to ssh public key for fileshare> :.ssh/id_rsa.pub
$ vagrant reload
```

We also now need to make sure that osxfuse is set up correctly;
macOS requires the user to accept that this signed binary is "okay to be loaded" by the kernel.
We can get `sshfs` to try to start the `osxfuse` kernel module by attempting to start it:

```sh
$ vagrant ssh -c 'mkdir testmnt && sshfs <fileshare ssh>:/Users/fileshare/share testmnt'
```

Then, you'll need to open the VM in VirtualBox, go to System Preferences,
go to Security & Privacy, General, unlock the settings,
and allow apps from the osxfuse developer to run.

Then, retry the above, and see if it works:

```sh
$ vagrant ssh -c 'sshfs <fileshare ssh>:/Users/fileshare/share testmnt'
```

if that works, you can now package the box:

```sh
$ vagrant ssh -c 'umount testmnt && rmdir testmnt'
$ vagrant package
```

This will create a `package.box`, which is the box file for the base VM.
Then, you can `vagrant box add <package.box> --name <name for the box>`,
and you'll have the base vcpkg box added for purposes of `Setup-VagrantMachines.ps1`!

Once you've created the base box, if you're making it the new base box for the CI,
upload it to the fileshare, under `share/vcpkg-boxes`.
Then, add the metadata about the box (the name and version) to the JSON file there.
Once you've done that, add the software versions below.

### VM Software Versions

* 2020-09-28:
  * macOS: 10.15.6
  * Xcode CLTs: 12

### (Internal) Accessing the macOS fileshare

The fileshare is located on `vcpkgmm-01`, under the `fileshare` user, in the `share` directory.
In order to get `sshfs` working on the physical machine,
you'll need to do the same thing one needs to do for building the base box:

```sh
$ brew cask install osxfuse && brew install sshfs
$ sudo shutdown -r now
```

Then, once you've ssh'd back in:

```sh
$ mkdir vagrant/share
$ sshfs fileshare@<vcpkgmm-01 URN>:/Users/fileshare/share vagrant/share
```

If you get an error, that means that gatekeeper has prevented the kernel extension from loading,
so you'll need to access the GUI of the machine, go to System Preferences,
Security & Privacy, General, unlock the settings, and allow apps from the osxfuse developer to run.
Then, you'll be able to add the fileshare as an sshfs.
