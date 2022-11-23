# Fedora e RedHat

  ## Steps:
  
 ### 1 - run this command in terminal:
  
  ```sh
  sudo dnf install vcpkg 
  ```
  
  ### 2 - Install the  dependencies:
  
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
  ### 3 - Install this group: (in new versions of fedora don't need install this group)
  
  ```sh
  sudo dnf group install "GROUPNAME"
   ```
  ### 4 - Install the devoloper packge of C e C++ for fedora:
  
  ```sh
  sudo dnf group install "C Development Tools and Libraries" "Development Tools"
  ```
  ### 5 - Download the last version of vcpkg with wget:
  
  ```sh
  wget -O vcpkg.tar.gz https://github.com/microsoft/vcpkg/archive/master.tar.gz
  ```
  ### 6 - Unzip the file:
  ```sh
  tar zxvf vcpkg.tar.gz
  ```
  ### 7 - Rename the unziped file:
  ```sh
  mv vcpkg-master vcpkg
  ```
  ### 8 - Move this file to /opt
  ```sh
  sudo mv vcpkg /opt/
  ```
  ### 9 - Run the shell script: (Microsoft does telemetry, if you want to enable telemetry by removing the -disableMetrics parameter)
  ```sh
  sudo /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics
  ```
  ### 10 Create a symbolic link for the command to be available on your $PATH:
  ```
  sudo ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg
  ```
  ### 11 Test the version
  ```sh
  vcpkg version
  ```
  ### 12 Cnfigure:
  
  #### 12.1 - Add the path to VCPKG_ROOT:
  ```sh
  echo 'export VCPKG_ROOT="/opt/vcpkg"' >> ~/.bashrc
source ~/.bashrc
```
  #### 12.2 - Create a symbolic link to the libraries:
  ```sh
  sudo ln -s /opt/vcpkg/installed/x64-linux/include /usr/local/include/vcpkg
  ```
  #### 12.3 - Enable the auto-complete:
  ```sh
  vcpkg integrate bash
source ~/.bashrc
```
  ### 13 - Finish 
  
  
  
  
  


    
      
     
    
  
  
