require 'json'

configuration = JSON.parse(File.read("#{__dir__}/vagrant-box-configuration.json"))

Vagrant.configure('2') do |config|
  config.vm.box = 'vcpkg/macos-base'
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
    inline: "brew install #{configuration['brew'].join(' ')} && brew install --cask #{configuration['brew-cask'].join(' ')}",
    privileged: false
end
