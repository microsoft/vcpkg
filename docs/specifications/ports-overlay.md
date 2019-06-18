# Ports Overlay (May 30, 2019)


## 1. Motivation

### A. Allow users to override ports with alternate versions

It's a common scenario for `vcpkg` users to keep specific versions of libraries to use in their own projects. The current recommendation for users is to fork `vcpkg`'s repository and create tags for commits containing the specific versions of the ports they want to use.

This proposal would add an alternative to solve this problem. By allowing `vcpkg` users to specify additional locations in their file system containing ports for:

  * old or newer versions of libraries,
  * modified libraries, or
  * libraries not available in `vcpkg`.

These locations will be searched when resolving port names during package installation, and override ports in `<vcpkg-root>/ports`.

### B. Allow users to keep unmodified upstream ports

Users would be able to keep unmodified versions of the ports shipped with `vcpkg` and update them via `vcpkg update` and `vcpkg upgrade` without having to solve merge conflicts.

### C. Allow users to maintain their own ports repositories.


## 2. Other design concerns

* Additional paths must be specified during `vcpkg install` using a new option: `--overlay-ports`.
* Additional paths must take precedence when resolving names of ports to install.
* Users should be able to specify multiple additional paths.
* The order in which additional paths are specified is used to solve ambiguous port names.
* This **DOES NOT ENABLE MULTIPLE VERSIONS** of a same library to be **INSTALLED SIDE-BY-SIDE**.
* After resolving a port name to a portfile, the installation process works the same as for ports shipped by `vcpkg`.


## 3. Proposed solution

This document proposes adding a new option `--overlay-ports` to the `vcpkg install`, `vcpkg update`, and `vcpkg upgrade` commands to specify additional paths containing ports. 

It is not the goal of this document to discuss library versioning or project dependency management solutions, which would require the ability to install multiple versions of a same library side-by-side. 

It proposes allowing additional locations to search for ports during package installation that would override and complement the set of ports provided by `vcpkg` (ports under the `<vcpkg_root>/ports` directory).

From a user experience perspective, a user expresses interest in adding additional lookup locations by passing the `--overlay-ports` option followed by paths to:

* directories containing ports,
  * `vcpkg install sqlite3 --overlay-ports=\\share\org\custom-ports`

* ports (directory containing a `portfile.cmake` file),
  * `vcpkg install sqlite3 --overlay-ports="C:\custom-ports\sqlite3"`

* and files listing paths to the former two.
  * `vcpkg install sqlite3 --overlay-ports=..\port-repos.txt`

    _port-repos.txt_
    
    ```
    .\experimental-ports\sqlite3
    C:\custom-ports
    \\share\team\custom-ports
    \\share\org\custom-ports
    ```
    *Relative paths inside this file are resolved relatively to the file's location. In this case a `experimental-ports` directory should exist at the same level as the `port-repos.txt` file.*

### Multiple additional paths 

Users can provide multiple additional paths:  
`vcpkg install sqlite3 --overlay-ports="..\experimental-ports\sqlite3" --overlay-ports="C:\custom-ports" --overlay-ports="\\share\team\custom-ports`

As a convenience, instead of repeating the `--overlay-ports` option, the user can provide a `;` delimited list:  
`vcpkg install sqlite3 --overlay-ports="..\experimental-ports\sqlite3;C:\custom-ports;\\\share\team\custom-ports`

### Overlaying ports

Port name resolution follows the order in which additional paths are specified, with the first match being selected for installation, and falling back to `<vcpkg-root>/ports` if the port is not found in any of the additional paths.

No effort is made to compare version numbers inside the `portfile.cmake` files, or to determine which port contains newer or older files.

### Examples

Given the following tree structure:

  ```
  team-ports/
  |-- sqlite3/
  |---- portfile.cmake
  |-- rapidjson/
  |---- portfile.cmake
  |-- curl/
  |---- portfile.cmake

  my-ports/
  |-- sqlite3/
  |----- portfile.cmake
  |-- rapidjson/
  |----- portfile.cmake

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

  Given that the contents on `preferred-ports.txt` are:

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

### i. User wants to preserve an older version of a port.

Developer Alice and her team use `vcpkg` to acquire **OpenCV** and some other packages. She has even contributed many patches to add features to the **OpenCV 3** port in `vckpg`. But, one day, she notices that a PR to update OpenCV to the next major version has been merged. 

Alice wants to update some packages available in `vcpkg`. Unfortunately, updating her project to use the latest OpenCV is not immediately possible. 

Alice creates a private GitHub repository and checks in the set of ports that she wants to preserve. Then provides her teammates with the link to clone her private ports repository.

```
mkdir vcpkg-custom-ports
cd vcpkg-custom-ports
git init 
cp -r %VCPKG_ROOT%/ports/opencv .
git add .
git commit -m "[opencv] Add OpenCV 3 port"
git remote add origin https://github.com/alice/vcpkg-custom-ports.git
git push -u origin master
```

Now her team is able to use: 

```
git clone https://github.com/alice/vcpkg-custom-ports.git
vcpkg upgrade --no-dry-run --overlay-ports=./vcpkg-custom-ports
``` 

to upgrade their packages and preserve the old version of `opencv` they require.
