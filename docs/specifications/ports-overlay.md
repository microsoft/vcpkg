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

From a user experience perspective, a user expresses interest in adding additional lookup locations by passing the `--aditional-ports` option followed by paths to directories containing `vcpkg` ports. E.g.:

```
vcpkg install sqlite3 --aditional-ports \\share\myorg\custom-ports
```


Users can specify multiple additional ports locations:

```
vcpkg install sqlite3 --additional-ports=C:\my-custom-ports --additional-ports=\\share\myteam\custom-ports --additional-ports=\\share\myorg\custom-ports
```

As a convenience users can create a file containing the additional paths and pass that to `vcpkg install`:

```
vcpkg install sqlite3 --aditional-ports=../port-repos.txt
```

_port-repos.txt_
```
./experimental-ports/opencv
C:/my-custom-ports
\\share\myteam\custom-ports
\\share\myorg\custom-ports
```

Relative paths inside this file are resolved relatively to the file's location.
In this case a `/experimental-ports` directory should exist at the same level as the `port-repos.txt` file.

A user can pass a combination of files and paths to the `vcpkg install <port> --additional-ports <paths>` command, files included in paths are expanded as if they were passed to the command line in order.

## 4. Proposed User experience

### TBD

## 5. Technical model

### TBD
