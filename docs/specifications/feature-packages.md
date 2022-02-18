# Proposal: Features / Feature packages (Feb 23 2017)

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

**Up-to-date documentation is available at [Selecting Library Features](../users/selecting-library-features.md).**

## 1. Motivation

### A. OpenCV + CUDA

[OpenCV][] is a computer vision library that can optionally be built with CUDA support to massively accelerate certain tasks when using computers with NVidia GPUs. For users without NVidia GPUs, building with CUDA support provides no benefit. [CUDA][] is provided only via a 1.3 GB installer (at the time of this authoring), which requires administrator access to install and modifies the global system state.

Therefore, there is significant value in enabling users to choose whether they find CUDA support valuable for their particular scenario.

### B. OpenCV + OpenCV\_contrib

The community around [OpenCV][] has built up a library of extensions called [OpenCV_contrib][]. However, these extensions are a source-level patch onto the main OpenCV codebase and therefore must be applied _during_ the core OpenCV build. Further confounding the problem, it is the author's understanding that these community extensions have only been developed with [CUDA][] enabled and cannot be built without that dependency.

Therefore, if CUDA is disabled, OpenCV\_contrib must also be disabled. Likewise, when a user requests OpenCV\_contrib, CUDA must be enabled. It would be convenient, but not a requirement, to enable CUDA without enabling the community extensions.

Finally, these extensions add additional exports and headers which could be depended upon by other libraries. For maintainers, there must be a way to specify this requirement such that `vcpkg install mylib-depends-ocv-contrib` will verify/build/rebuild OpenCV with the community extensions enabled.

### C. C++ REST SDK + SignalR

The [C++ REST SDK][cpprestsdk] is a networking library that provides (among other features) HTTP and Websockets clients. To implement the HTTP client functionality on Windows Desktop, only the core Win32 platform APIs are needed (`zlib` is optional).

However, the websockets client is based on [Websockets++][], which adds mandatory dependencies on `boost`, `openssl`, and `zlib`. Many users of the C++ REST SDK do not use the websockets component, so to minimize their overall dependency footprint it can be disabled at build time. Ideally, these kinds of options would be easily accessible to users in Vcpkg who are concerned about the final size or licensing of their deployment.

[SignalR-Client-Cpp][SignalR] depends on the websockets functionality provided by the C++ REST SDK. Therefore, the maintainers of the `signalrclient` port would ideally like to express this dependency such that `cpprestsdk` will be automatically correctly built for their needs. Note that `signalrclient` does not _inherently_ care about `boost`, `websocketspp` or `openssl` -- it depends only on the public websocket client APIs provided by `cpprestsdk`. It would be much more maintainable to declare dependencies based on the public APIs rather than the dependencies themselves.

[OpenCV]: http://opencv.org/
[CUDA]: http://www.nvidia.com/object/cuda_home_new.html
[OpenCV_contrib]: https://github.com/opencv/opencv_contrib
[cpprestsdk]: https://github.com/Microsoft/cpprestsdk
[Websockets++]: https://www.zaphoyd.com/websocketpp/
[SignalR]: https://github.com/aspnet/SignalR-Client-Cpp

## 2. Other design concerns

- General-purpose Open Source projects must be able to easily and succinctly describe their build dependencies inside Vcpkg. This should be no more verbose than a single `vcpkg install` line and, when that command succeeds, there is a strong expectation that all required functionality/headers/imports are available.

- The internal state of the Vcpkg enlistment must be either extremely transparent OR managed by version control (git). This enables larger projects to efficiently transfer the entire state of their customized Vcpkg system between machines (and onto build servers) by having the destination clone and then run a single `vcpkg install` line for the subset of dependencies required. The results of this operation should be as repeatable as reasonably achievable given the current limits of the underlying toolchain.

## 3. Proposed solution

A key summary of the above motivations is that they are all scenarios surrounding APIs that are not independently buildable from each other. We have an existing solution for APIs that are independently buildable: separate packages. Therefore, we seek to extend the user-facing notion of "packages" to include capabilities and contracts that cannot be made into independent builds.

This document proposes "features" (also called feature packages). These features are intended to model semi-independently toggleable API sets/contracts such that they can be sanely depended upon by other packages. It is not a goal to model exclusive alternatives (such as implementation choices that are not directly user-observable) through this mechanism.

- Individual libraries within `boost` may be reasonably represented as features.
- Whether a graphics library is built on DirectX xor OpenGL (where one but not both must be chosen) is not representable as a feature.

From a user experience perspective (i.e. from `vcpkg install`) feature packages act as much as possible like completely independent packages. However, internally, any change to a package's features will result in a rebuild of the associated "parent" package. This will invoke a package rebuild experience similar to upgrading.

When using `vcpkg install <package>`, some features will be enabled by default. These default features can be avoided by referring to the packages as `<package>[core]` and features can be added by supplying them on the same installation line.

### A. Proposed User experience

#### i. User with no preference about options
Install of a library with default features:
```no-highlight
> vcpkg install cpprestsdk
// -- omitted build information -- //
Package cpprestsdk[core]:x86-windows is installed.
Package cpprestsdk[compression]:x86-windows is installed.
Package cpprestsdk[ws-client]:x86-windows is installed.
```

Removal of that library:
```no-highlight
> vcpkg remove cpprestsdk
The following packages will be removed:
    cpprestsdk:x86-windows
Removing package cpprestsdk:x86-windows...
Removing package cpprestsdk:x86-windows... done
Purging package cpprestsdk:x86-windows...
Cleaned up D:\src\vcpkg\packages\cpprestsdk_x64-windows
Purging package cpprestsdk:x86-windows... done
```

Installation of a library with optional features:
```no-highlight
> vcpkg install opencv
// -- omitted build information -- //
Package opencv[core]:x86-windows is installed.
```

#### ii. User desires CUDA support for OpenCV directly, and is unfamiliar with feature packages
Developer Bob knows he wants OpenCV, so he guesses what the package is called
```no-highlight
> vcpkg install opencv
// -- omitted build information -- //
Package opencv[core]:x86-windows is installed.
```

Bob attempts to build his application against OpenCV (assuming CUDA), which fails at runtime or compile time indicating that OpenCV wasn't built with CUDA.
Bob comes back to vcpkg, not knowing about the "feature packages" feature. The primary inquiry tools for Vcpkg are `search` and `list`, so he runs `vcpkg search`:
```no-highlight
> vcpkg search opencv
opencv               3.2.0            computer vision library
opencv[cuda]                          support for NVidia CUDA
opencv[contrib]                       community supported extensions for OpenCV

If your library is not listed, please open an issue at:
    https://github.com/Microsoft/vcpkg/issues
```
He isn't immediately sure what the lack of a version number means, but anything in `vcpkg search` can be applied to `vcpkg install`, so he runs:
```no-highlight
> vcpkg install opencv[cuda]
The following packages will be rebuilt:
    opencv:x86-windows

To rebuild with this feature, use:
    vcpkg remove opencv:x86-windows
    vcpkg install opencv[core,cuda]:x86-windows
```
Bob follows the instructions...
```no-highlight
> vcpkg remove opencv:x86-windows
// -- omitted results as above -- //
> vcpkg install opencv[core,cuda]:x86-windows
// -- omitted build information -- //
Package opencv[core]:x86-windows is installed.
Package opencv[cuda]:x86-windows is installed.
```
and he can now use OpenCV's CUDA support in his application.

#### iii. User is familiar with feature packages, and wants to opt-out of a feature
Developer Alice has used `cpprestsdk`, built it from source, and she knows about the option to disable websockets. She uses `search` to find the complete list of features:
```
> vcpkg search cpprestsdk
cpprestsdk                  2.9.0-2       C++11 JSON, REST, and OAuth library The C++ RES...
cpprestsdk[compression]                   Gzip compression support in the HTTP client.
cpprestsdk[ws-client]                     Websocket client support based on websocketspp.

If your library is not listed, please open an issue at:
    https://github.com/Microsoft/vcpkg/issues
```

She decided she only wants `cpprestsdk[compression]`, so she installs only that feature:
```no-highlight
> vcpkg install cpprestsdk[compression]
// -- omitted build information -- //
Package cpprestsdk[core]:x86-windows is installed.
Package cpprestsdk[compression]:x86-windows is installed.
```
She receives a quick recursive build that only depends on `zlib`.

She's now interested in some additional libraries built on top of cpprestsdk: `azure-storage-cpp` and `signalrclient`.
```no-highlight
> vcpkg install azure-storage-cpp
// -- omitted build information -- //
Package azure-storage-cpp[core]:x86-windows is installed.

> vcpkg install signalrclient
Package signalrclient:x86-windows depends on cpprestsdk[ws-client]:x86-windows.

The following packages will be rebuilt:
  * azure-storage-cpp:x86-windows
  * cpprestsdk:x86-windows

To rebuild the current package graph with this feature, use:
    vcpkg remove cpprestsdk:x86-windows azure-storage-cpp:x86-windows
    vcpkg install cpprestsdk[core,compression,ws-client]:x86-windows
    vcpkg install azure-storage-cpp[core]:x86-windows
    vcpkg install signalrclient[core]:x86-windows
```
She follows the above script and can use both `azure-storage-cpp` and `signalrclient` in her code.

Some time has passed, she decided not to use `signalrclient`, and she's interested in shipping her application. She wants to minimize her final install size, so she'd like to remove all unneeded packages like `boost` and `openssl`.
```no-highlight
> vcpkg remove boost openssl
The following packages and features will be removed:
  * signalrclient[core]:x86-windows
  * cpprestsdk[ws-client]:x86-windows
    boost[core]:x86-windows
    openssl[core]:x86-windows

The following packages will be rebuilt:
  * azure-storage-cpp:x86-windows
  * cpprestsdk:x86-windows

Removing features requires rebuilding packages.
To rebuild the current package graph without these features, use:
    vcpkg remove cpprestsdk:x86-windows azure-storage-cpp:x86-windows signalrclient:x86-windows openssl:x86-windows boost:x86-windows
    vcpkg install cpprestsdk[core,compression]:x86-windows
    vcpkg install azure-storage-cpp[core]:x86-windows
```
In the end, her final `vcpkg list` outputs:
```no-highlight
> vcpkg list
zlib[core]:x86-windows              1.2.11          A compression library
azure-storage-cpp[core]:x86-windows 2.6.0           Microsoft Azure Storage Client SDK for ...
cpprestsdk[core]:x86-windows        2.9.0-2         C++11 JSON, REST, and OAuth library
cpprestsdk[compression]:x86-windows                 Gzip compression support in the HTTP client.
```

### B. Technical model

- Each package can have any number "features".
- Features follow the same naming conventions as packages, but when referenced are always "namespaced" by the parent package.
    - `cpprestsdk[ws-client]` is a completely orthogonal feature from `poco[ws-client]`.
- Features are valid dependencies.
    - `signalrclient` depends on `cpprestsdk[ws-client]`
- Features can have dependencies (including other features).
    - `cpprestsdk[ws-client]` depends on `boost`, `openssl`, and `websocketspp`
    - `opencv[cuda]` depends on `cuda`
    - `opencv[contrib]` depends on `opencv[cuda]`
    - `boost[python]` depends on `libpython`
- Every package has an implicit feature called `core`, which covers the core library with a minimum set of features. All features implicitly depend on the `core` feature of their parent package
    - `azure-storage-cpp` depends on `cpprestsdk[core]`
    - `cpprestsdk[ws-client]` implicitly depends on `cpprestsdk[core]`
- Each package declares a list of default features that are enabled when the package is referred to by its raw name, and `core` is always a default feature.
    - `cpprestsdk` declares `ws-client` and `compression` to be default features. Any unqualified reference `cpprestsdk` implicitly means `cpprestsdk[core]` _and_ `cpprestsdk[ws-client]` _and_ `cpprestsdk[compression]`.
    - `opencv` does not declare `cuda` nor `contrib` to be default features.

As a conclusion of the above, it is expected that all packages will be buildable with all features disabled (just the `core` feature) and with all features enabled.

### C. Proposed Control File Syntax

#### OpenCV and CUDA
To add the feature CUDA to OpenCV, we will adopt the following syntax in the CONTROL file:
```no-highlight
# opencv/CONTROL
Source: opencv
Version: 3.2.0-1
Build-Depends: zlib, libpng, libjpeg-turbo, tiff
Description: computer vision library
Default-Features:

Feature: cuda
Build-Depends: cuda
Description: parallel computing platform

Feature: contrib
Build-Depends: opencv[cuda]
Description: library of OpenCV Extensions
```

#### Signalrclient
```no-highlight
# signalrclient/CONTROL
Source: signalrclient
Version: 1.0.0-beta1
Build-Depends: cpprestsdk[ws-client]
Description: C++ client for SignalR.
```
```no-highlight
# cpprestsdk/CONTROL
Source: cpprestsdk
Version: 2.9.0-2
Build-Depends: 
Description: C++11 JSON, REST, and OAuth library ...
Default-Features: compression, ws-client

Feature: compression
Build-Depends: zlib (windows)
Description: Gzip compression support in the HTTP client.

Feature: ws-client
Build-Depends: boost (windows), openssl (windows), websocketpp (windows)
Description: Websocket client support based on websocketspp
```

### D. Additional Control File Technical Details

- If any feature paragraphs exist, the field `Default-Features` must be present.

## 4. Related Work

### Cargo's Features (from Rust): <http://doc.crates.io/manifest.html#the-features-section>
The proposed feature packages are exceedingly similar to Cargo's Features, with the following changes:

- We avoid any collision problems because features are always namespaced by the owning package
- We do not have a concept of "feature groups", instead we allow dependencies from one feature to another within the same package (Note: This may be how "feature groups" are implemented internally to Cargo -- it was not clear from the documentation).
- Because of the nature of C and C++, it is extremely commonplace that large software packages can have features disabled to remove their dependencies upon other libraries. Changing this configuration requires a rebuild of the package and potentially rippling ABI changes to any downstream dependencies. Therefore, we expect significantly more use of this feature to manage optional API contracts instead of the intended use in Cargo (curation).
- We do not intend feature packages to be used to express the curation relationship, beyond the notion of a "default" set within a package.

### Gentoo's USE flags: <https://wiki.gentoo.org/wiki/Handbook:X86/Working/USE>
Gentoo's USE flags can be shortly summarized as a global set of keywords that is used to make cross-cutting changes to the entire package graph's build configuration. This system standardizes many common settings such that they can be simultaneously toggled for the entire graph.

The most common example of this would be using KDE vs Gnome. A user who knows that, given the choice, they would prefer the KDE/Qt interface can manage the massive space of package configuration efficiently without learning the particular term that each package has decided to call "build using Qt instead of GTK".

USE flags can be customized hierarchically when needed, including at the per-package level. They can be depended upon by other packages, both positively and negatively. USE flags themselves can be used in any boolean expression to determine the complete set of package dependencies, including removing dependencies when flags are enabled.

Problems with USE flags:

- They require coordination from package maintainers to achieve the goal of "portable" flags. This increases the burden of adding a package -- to author a good package, I need to be aware of every uncommon USE flag and evaluate how those could map onto my local configuration space.
- Based on research online, it seems extremely common that users need to tweak flags at a per-package level. This calls into question how valuable the cross-cutting power above is.
- The vast majority of common USE flags are essentially a list of all the common packages and focus on giving the user a view of dependencies (which a package manager is designed to abstract when possible) instead of APIs (which is what users code against).
- Dependency analysis with USE flags becomes a SAT problem with an enormous state space -- P*F bits -- which compounds with any versioning relations. This may work acceptably in practice via heuristics, but it implies that a) there is a looming performance wall which could suddenly create a poor user experience and b) the heuristics may incorrectly model the user's needs, causing a disconnect in desire vs practice, which again leads to a poor user experience.
