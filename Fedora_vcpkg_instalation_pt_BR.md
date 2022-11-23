# Fedora e RedHat

  ## Passo a passo:
  
 ## 1 - Rode esses comandos no terminal:
  
  ```sh
  sudo dnf install vcpkg 
  ```
  
  ### 2 - instale as dependências:
  
  ```sh
  sudo dnf install git
  ```
  ```sh
  sudo dnf install g++
  ```
  ```sh
  sudo dnf install tar
  ```
  ```sh
  sudo dnf install curl
  ```
  ```sh
  sudo dnf install zip
  ```
  ```sh
  sudo dnf install unzip
  ```
  ```sh
  sudo dnf install vim
  ```
  ### 3 - Instale esse grupo: (nas novas versões do Fedora não precisa instalar)
  
  ```sh
  sudo dnf group install "GROUPNAME"
   ```
  ### 4 - Instale o devoloper packge de C e C++ para o Fedora:
  
  ```sh
  sudo dnf group install "C Development Tools and Libraries" "Development Tools"
  ```
  ### 5 - Faça o download da última versão com o wget:
  
  ```sh
  wget -O vcpkg.tar.gz https://github.com/microsoft/vcpkg/archive/master.tar.gz
  ```
  ### 6 - Descompacte o arquivo:
  ```sh
  tar zxvf vcpkg.tar.gz
  ```
  ### 7 - enomeie o diretório que foi descompactado:
  ```sh
  mv vcpkg-master vcpkg
  ```
  ### 8 - Mova o arquivo para /opt:
  ```sh
  sudo mv vcpkg /opt/
  ```
  ### 9 - Rode o shell script: (A Microsoft faz telemetria, se quiser habilitar a telemetria, remova o parâmetro -disableMetrics)
  ```sh
  sudo /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics
  ```
  ### 10 Crie um link simbólico para o comando ficar disponível na sua $PATH:
  ```
  sudo ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg
  ```
  ### 11 Teste pra ver se está tudo certo:
  ```sh
  vcpkg version
  ```
  ### 12 configurações:
  
  #### 12.1 - Adicione o caminho ao VCPKG_ROOT:
  ```sh
  echo 'export VCPKG_ROOT="/opt/vcpkg"' >> ~/.bashrc
source ~/.bashrc
```
  #### 12.2 - Crie um link simbólico para as bibliotecas:
  ```sh
  sudo ln -s /opt/vcpkg/installed/x64-linux/include /usr/local/include/vcpkg
  ```
  #### 12.3 - Habilite o autocomplete:
  ```sh
  vcpkg integrate bash
source ~/.bashrc
```
  ### 13 - Finalizando
  ```sh
  sudo dnf check-update
  ```
  ```sh
  sudo dnf upgrade
  ```
