# Ports Overlay (Jun 19, 2019)

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

## 1. Motivation

### A. Allow users to override ports with alternate versions

It's a common scenario for `vcpkg` users to keep specific versions of libraries to use in their own projects. The current recommendation for users is to fork `vcpkg`'s repository and create tags for commits containing the specific versions of the ports they want to use.

This proposal adds an alternative to solve this problem. By allowing `vcpkg` users to specify additional locations in their file system containing ports for:

  * older or newer versions of libraries,
  * modified libraries, or
  * libraries not available in `vcpkg`.

These locations will be searched when resolving port names during package installation, and override ports in `<vcpkg-root>/ports`.

### B. Allow users to keep unmodified upstream ports

Users will be able to keep unmodified versions of the ports shipped with `vcpkg` and update them via `vcpkg update` and `vcpkg upgrade` without having to solve merge conflicts.


## 2. Other design concerns

* Allow a set of `vcpkg` commands to optionally accept additional paths to be used when searching for ports.
* Additional paths must take precedence when resolving names of ports to install.
* Allow users to specify multiple additional paths.
* Provide a simple disambiguation mechanism to resolve ambiguous port names.
* After resolving a port name, the installation process has to work the same as for ports shipped by `vcpkg`.
* This **DOES NOT ENABLE MULTIPLE VERSIONS** of a same library to be **INSTALLED SIDE-BY-SIDE**.


## 3. Proposed solution

This document proposes allowing additional locations to search for ports during package installation that will override and complement the set of ports provided by `vcpkg` (ports under the `<vcpkg_root>/ports` directory).`

A new option `--overlay-ports` will be added to the `vcpkg install`, `vcpkg update`, `vcpkg upgrade`, `vcpkg export`, and `vcpkg depend-info` commands to specify additional paths containing ports. 

From a user experience perspective, a user expresses interest in adding additional lookup locations by passing the `--overlay-ports` option followed by a path to:

* an individual port (directory containing a `CONTROL` file),
  * `vcpkg install sqlite3 --overlay-ports="C:\custom-ports\sqlite3"`

* a directory containing ports,
  * `vcpkg install sqlite3 --overlay-ports=\\share\org\custom-ports`

* a file listing paths to the former two.
  > NOTE: Reading paths from a text file is not available in the current implementation, some revisions to this part of the specification are being made and will be implemented in a future date.
  
  * `vcpkg install sqlite3 --overlay-ports=..\port-repos.txt`

    _port-repos.txt_
    
    ```
    .\experimental-ports\sqlite3
    C:\custom-ports
    \\share\team\custom-ports
    \\share\org\custom-ports
    ```
    *Relative paths inside this file are resolved relatively to the file's location. In this case a `experimental-ports` directory should exist at the same level as the `port-repos.txt` file.*

_NOTE: It is not the goal of this document to discuss library versioning or project dependency management solutions, which require the ability to install multiple versions of a same library side-by-side._ 

### Multiple additional paths 

Users can provide multiple additional paths by repeating the `--overlay-ports` option.

```
vcpkg install sqlite3 
    --overlay-ports="..\experimental-ports\sqlite3" 
    --overlay-ports="C:\custom-ports" 
    --overlay-ports="\\share\team\custom-ports
```

### Overlaying ports

Port name resolution follows the order in which additional paths are specified, with the first match being selected for installation, and falling back to `<vcpkg-root>/ports` if the port is not found in any of the additional paths.

No effort is made to compare version numbers inside the `CONTROL` files, or to determine which port contains newer or older files.

### Examples

Given the following directory structure:

  ```
  team-ports/
  |-- sqlite3/
  |---- CONTROL
  |-- rapidjson/
  |---- CONTROL
  |-- curl/
  |---- CONTROL

  my-ports/
  |-- sqlite3/
  |---- CONTROL
  |-- rapidjson/
  |---- CONTROL

  vcpkg
  |-- ports/
  |---- <upstream ports>
  |-- vcpkg.exe
  |-- preferred-ports.txt
  ```
* #### Example #1:

  Running:

  ```
  vcpkg/vcpkg.exe install sqlite3 --overlay-ports=my-ports --overlay-ports=team-ports
  ```

  Results in `my-ports/sqlite3` getting installed as that location appears first in the command line arguments.

* #### Example #2:
  
  A specific version of a port can be given priority by adding its path first in the list of arguments:

  ```
  vcpkg/vcpkg.exe install sqlite3 rapidjson curl 
      --overlay-ports=my-ports/rapidjson 
      --overlay-ports=vcpkg/ports/curl
      --overlay-ports=team-ports
  ```

  Installs:
    * `sqlite3` from `team-ports/sqlite3`
    * `rapidjson` from `my-ports/rapidjson`
    * `curl` from `vcpkg/ports/curl`

* #### Example #3:

  > NOTE: Reading paths from a text file is not available in the current implementation, some revisions to this part of the specification are being made and will be implemented in a future date.
  
  Given the content of `preferred-ports.txt` as:

  ```
  ./ports/curl
  /my-ports/rapidjson
  /team-ports
  ```

  A location can be appended or prepended to those included in `preferred-ports.txt` via the command line, like this:

  ```
  vcpkg/vcpkg.exe install sqlite3 curl --overlay-ports=my-ports --overlay-ports=vcpkg/preferred-ports.txt
  ```

  Which results in `my-ports/sqlite3` and `vcpkg/ports/curl` getting installed.


## 4. Proposed User experience

### i. User wants to preserve an older version of a port

Developer Alice and her team use `vcpkg` to acquire **OpenCV** and some other packages. She has even contributed many patches to add features to the **OpenCV 3** port in `vcpkg`. But, one day, she notices that a PR to update **OpenCV** to the next major version has been merged. 

Alice wants to update some packages available in `vcpkg`. Unfortunately, updating her project to use the latest **OpenCV** is not immediately possible. 

Alice creates a private GitHub repository and checks in the set of ports that she wants to preserve. Then provides her teammates with the link to clone her private ports repository.

```
mkdir vcpkg-custom-ports
cd vcpkg-custom-ports
git init 
cp -r %VCPKG_ROOT%/ports/opencv .
git add .
git commit -m "[opencv] Add OpenCV 3 port"
git remote add origin https://github.com/<Alice's GitHub username>/vcpkg-custom-ports.git
git push -u origin master
```

Now her team is able to use: 

```
git clone https://github.com/<Alice's GitHub username>/vcpkg-custom-ports.git
vcpkg update --overlay-ports=./vcpkg-custom-ports
vcpkg upgrade --no-dry-run --overlay-ports=./vcpkg-custom-ports
``` 

to upgrade their packages and preserve the old version of **OpenCV** they require.
