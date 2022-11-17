require 'json'

configuration = JSON.parse(File.read("#{__dir__}/vagrant-configuration.json"))

server = {
  :machine_name => configuration['machine_name'],
  :box => configuration['box_name'],
  :box_version => configuration['box_version'],
  :ram => 24000,
  :cpu => 11
}

azure_agent_url = 'https://vstsagentpackage.azureedge.net/agent/2.198.3/vsts-agent-osx-x64-2.198.3.tar.gz'
devops_url = configuration['devops_url']
agent_pool = configuration['agent_pool']
pat = configuration['pat']

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
