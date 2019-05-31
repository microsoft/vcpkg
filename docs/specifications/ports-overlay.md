# Ports Overlay (May 30, 2019)

## 1. Motivation

### A. Allow users to override ports with alternate versions

It's a common scenario for `vcpkg` users to keep specific versions of libraries to use in their own projects. The current recommendation for users is to fork `vcpkg`'s repository and create tags for commits containing the specific versions of the ports they want to use.

This proposal would add an alternative to solve this problem. By allowing `vcpkg` users to specify additional locations in their file system containing ports for:

  * old or newer versions of libraries,
  * modified libraries, or
  * libraries not available in `vcpkg`;

which will take precedence when resolving a port name during a `vcpkg install`.


### B. Allow users to keep unmodified upstream ports

Users would be able to keep unmodified versions of the ports shipped with `vcpkg` and update them via `vcpkg update` without having to solve merge conflicts.


### C. Allow users to mantain their own ports repositories.


## 2. Other design concerns

* Additional paths must be specified during `vcpkg install` using a new option: `--additional-ports`.
* Additional paths must take precedence when resolving names of ports to install.
* Users should be able to specify multiple additional paths.
* The order in which additional paths are specified is used to solve ambiguous port names.
* This **DOES NOT ENABLE MULTIPLE VERSIONS** of a same library to be **INSTALLED SIDE-BY-SIDE**.
* After resolving a port name to a portfile, the installation process works the same as for ports shipped by `vcpkg`.

## 3. Proposed solution

This document proposes adding a new option `--additional-ports` to the `vcpkg install` command to specify additional paths containing ports. It is not the goal of this document to discuss library versioning or project dependency management solutions, which would require the ability to install multiple versions of a same library side-by-side. It proposes allowing additional locations to search for ports during `vcpkg install` that would override and complement the set of ports provided by `vcpkg` (ports under the `<vcpkg_root>/ports` directory).

From a user experience perspective, a user expresses interest in adding additional lookup locations by passing the `--aditional-ports` option followed by paths to:


* #### directories containing ports
  * `vcpkg install sqlite3 --additional-ports=\\share\org\custom-ports`


* #### ports (directory containing a `portfile.cmake` file)
  * `vcpkg install sqlite3 --additional-ports="C:\custom-ports\sqlite3"`

* #### files listing paths to the former two
  * `vcpkg install sqlite3 --additional-ports=../port-repos.txt`

    _port-repos.txt_
    
    ```
    ./experimental-ports/sqlite3
    C:\custom-ports
    \\share\team\custom-ports
    \\share\org\custom-ports
    ```
    *Relative paths inside this file are resolved relatively to the file's location. In this case a `/experimental-ports` directory should exist at the same level as the `port-repos.txt` file.*

### Multiple additional paths 

Users can provide multiple additional paths:  
`vcpkg install sqlite3 --additional-ports="../experimental-ports/sqlite3" --additional-ports="C:\custom-ports" --additional-ports="\\share\team\custom-ports`

As a convenience, instead of repeating the `--additional-ports` option, the user can provide a `;` delimited list:  
`vcpkg install sqlite3 --additional-ports="../experimental-ports/sqlite3;C:\custom-ports;\\\share\team\custom-ports`

### Overlaying ports

Port name resolution follows the order in which additional paths are specified, with the first match being selected for installation, and falling back to `<vcpkg-root>/ports` if the port is not found in any of the additional paths.

No effort is made to compare version numbers inside the `portfile.cmake` files, or to determine which port contains newer or older files.

* #### Example #1:

  Running

  `vcpkg install sqlite3 --additional-dirs=/team-ports --additional-dirs=/vcpkg/my-ports`  

  given the following tree structure:

  ```
  /team-ports
  |-- /sqlite3
  |---- portfile.cmake
  |-- /rapidjson
  |---- portfile.cmake


  /my-ports
  |-- /sqlite3
  |----- portfile.cmake
  |-- /rapidjson
  |----- portfile.cmake
  |-- /curl
  |---- portfile.cmake

  /vcpkg
  |-- /ports
  |---- <upstream ports>

  preferred-ports.txt
  ```

  would result in `/team-ports/sqlite3` getting installed as that location appears first in the command line arguments.

* #### Example #2:
  
  A specific version of a port can be given priority by adding its path first in the list of arguments:

  ```
  vcpkg install sqlite3 rapidjson curl 
      --additional-dirs=/my-ports/rapidjson 
      --additional-dirs=/team-ports
      --additional-dirs=/vcpkg/ports/curl
      --additional-dirs=/my-ports
  ```

  Would install:
    * `sqlite3` from `/team-ports/sqlite3`
    * `rapidjson` from `/my-ports/rapidjson`
    * `curl` from `/vcpkg/ports/curl`

  Note that given that order, if `/team-ports` contained a `curl` port, it would be given priority over `/vcpkg/ports/curl`.

* #### Example #3:

  Given the contents on `preferred-ports.txt` are:

  ```
  /vcpkg/ports/curl
  /my-ports/rapidjson
  /team-ports
  ```

  A location can be appended or preppended to those included in `preferred-ports.txt` via the command line, like this:

  `vcpkg install sqlite3 curl --additional-ports=/my-ports --additional-ports=/preferred-ports.txt` 

  which would result in `/my-ports/sqlite3` and `/vcpkg/ports/curl` being installed.

## 4. Proposed User experience

### TBD

## 5. Technical model

### TBD
