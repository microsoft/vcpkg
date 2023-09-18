Vagrant.configure('2') do |config|
  config.vm.box = 'macos-13-5'
  config.vm.synced_folder '.', '/Users/vagrant/shared'

  config.vm.provision 'shell',
    run: 'once',
    name: 'Install Xcode Command Line Tools: attach dmg file',
    inline: 'hdiutil attach shared/clt.dmg -mountpoint /Volumes/setup-installer',
    privileged: false
  config.vm.provision 'shell',
    run: 'once',
    name: 'Install Xcode Command Line Tools: run installer',
    inline: 'installer -pkg "/Volumes/setup-installer/Command Line Tools.pkg" -target /',
    privileged: true
  config.vm.provision 'shell',
    run: 'once',
    name: 'Install XCode Command Line Tools: detach dmg file',
    inline: 'hdiutil detach /Volumes/setup-installer',
    privileged: false

  config.vm.provision 'shell',
    run: 'once',
    name: 'Install brew',
    inline: '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"',
    privileged: false
  config.vm.provision 'shell',
    run: 'once',
    name: 'Install brew applications',
    inline: "brew install autoconf-archive autoconf automake bison cmake gettext gfortran gperf gtk-doc libtool meson mono nasm ninja pkg-config powershell texinfo yasm",
    privileged: false
end
