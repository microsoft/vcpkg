server = {
  :machine_name => 'vcpkg-eg-mac-11',
  :box => 'vcpkg-macos-2023-09-11',
  :box_version => '0',
  :ram => 24000,
  :cpu => 12
}

azure_agent_url = 'https://vstsagentpackage.azureedge.net/agent/3.225.0/vsts-agent-osx-x64-3.225.0.tar.gz'
devops_url = 'https://dev.azure.com/vcpkg'
agent_pool = 'PrOsx-2023-09-11'
pat = '<replace with PAT>'

Vagrant.configure('2') do |config|
  config.vm.box = server[:box]
  config.vm.box_version = server[:box_version]
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider 'parallels' do |prl|
    prl.memory = server[:ram]
    prl.cpus = server[:cpu]
  end

  config.vm.provision 'shell',
    run: 'once',
    name: 'Create the data directory',
    inline: "mkdir ~/Data",
    privileged: false

  config.vm.provision 'shell',
    run: 'once',
    name: 'Download azure agent',
    inline: "curl -s -o ~/Downloads/azure-agent.tar.gz #{azure_agent_url}",
    privileged: false

  config.vm.provision 'shell',
    run: 'once',
    name: 'Unpack azure agent',
    inline: 'mkdir myagent; cd myagent; tar xf ~/Downloads/azure-agent.tar.gz',
    privileged: false

  config.vm.provision 'shell',
    run: 'once',
    name: 'Add VM to azure agent pool',
    inline: "cd ~/myagent;\
      ./config.sh --unattended \
        --url #{devops_url} \
        --work ~/Data/work \
        --auth pat --token #{pat} \
        --pool #{agent_pool} \
        --agent #{server[:machine_name]} \
        --replace \
        --acceptTeeEula",
    privileged: false

  # Start listening for jobs
  config.vm.provision 'shell',
    run: 'always',
    name: 'Start running azure pipelines',
    inline: 'cd /Users/vagrant/myagent;\
      nohup ./run.sh&',
    privileged: false
end
