# Binary Export (Apr 28, 2017)

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

## 1. Motivation

### A. Build once and share

Customers want to be able to build their set of required libraries once, and then distribute the resulting binaries to all members of the "group". This has been brought up in
- Enterprise environments, in which there are dedicated teams to acquire libraries and then share them with other teams to consume them
- Academic environments, in which the professor/teacher wants to build the required libraries and then provide them to all the students
- CI Systems, in which developers want to quickly distribute their exact set of dependencies to a cloud-based farm of build machines

Building once and sharing ensures that everyone gets exactly the same binaries, isolates the building effort to a small number of people and minimizes friction to obtain them. Therefore, there is value in enabling users to easily export ready-to-share binaries from `vcpkg`.

### B. Very large libraries

Libraries like [Qt][] can take a very long time to build (5+ hours). Therefore, having the ability to build them and then distribute the binaries can save a lot of time.

### C. Flexibility and uses without `vcpkg`

`vcpkg` currently handles cases where you have a `vcpkg` enlistment on your machine and use it for acquiring libraries and integrating into Visual Studio, CMake etc. However, users need the ability to build the libraries and then use them outside of and independently of `vcpkg`. For example:
- Use `vcpkg` for the build, then host the binaries in a website (similarly to nuget)
- Use `vcpkg` for the build, then put the binaries in an installer and distribute the installer

Consuming the libraries outside of `vcpkg` forfeits the ability to install new libraries or update existing ones, but this can be:
- not a concern, like in a short term project or assignment
- explicitly desired, like in the development of a game where libraries and their versions are sealed for a particular release, never to be modified

### D. Easy consumption in Visual Studio for NuGet users

Customers have requested C++ NuGet packages to integrate into their project. This has come from:
- Customers than have used NuGet (e.g. in C#) and find it very convenient
- Customers who are working on a C# project that has a few dependencies on C++ and just want those dependencies to be satisfied in the most automatic way possible

Providing a way to create NuGet packages provides great value to those customers. In an enterprise environment which focuses on C#, the dedicated acquisition team can create the NuGet packages with `vcpkg` and provide them to the other developers. For the "end-developer", this makes the consumption of C++ libraries the same as C# ones.

[Qt]: https://www.qt.io/

## 2. Other design concerns

- The `vcpkg` root may have a variety of packages built and many of them might be unrelated to the current task. Providing an easy way to export a subset of them will enhance user experience.
- Since binary compatibility is not guaranteed, it is not safe to individually export packages. Therefore, when exporting a particular package, all of the dependencies that it was built against must also be present in the export format (e.g. zip file). When a `vcpkg export` command succeeds, there is a guarantee that all required headers/binaries are available in the target bundle.

## 3. Proposed solution

This document proposes the `vcpkg export` command to pack the desired binaries in a convenient format. It is not the goal of this document to discuss binary distribution for C++ in a similar way that NuGet does for C#. It proposes exporting "library sets" instead of individual libraries as a solution to the C++ binary incompatibility problem.

From a user experience perspective, the user expresses interest in exporting a particular library (e.g. `vcpkg export cpprestsdk`). `vcpkg export` should then make sure that the output contains `cpprestsdk` along with all dependencies it was actually built against.

## 4. Proposed User experience

### i. User knows what libraries he needs and wants to export them to an archive format (zip)
Developer Bob needs gtest and cpprestsdk and has been manually building them and their dependencies, then using the binaries in his project via applocal deployment. Bob has been experimenting with `vcpkg` and wants to use `vcpkg` for the building part only.

Bob tries to export the libraries:
```no-highlight
> vcpkg export gtest cpprestsdk --zip
The following packages are already built and will be exported:
  * boost:x86-windows
  * bzip2:x86-windows
    cpprestsdk:x86-windows
  * openssl:x86-windows
  * websocketpp:x86-windows
  * zlib:x86-windows
The following packages need to be built:
    gtest:x86-windows
Additional packages (*) need to be exported to complete this operation.
There are packages that have not been built.
To build them, run:
    vcpkg install gtest:x86-windows
```

Bob proceeds to install the missing libraries:
```no-highlight
> vcpkg install gtest:x86-windows
// -- omitted build information -- //
Package gtest:x86-windows is installed.
```

Bob then returns to export the libraries:
```no-highlight
> vcpkg export gtest cpprestsdk --zip
The following packages are already built and will be exported:
  * boost:x86-windows
  * bzip2:x86-windows
    cpprestsdk:x86-windows
    gtest:x86-windows
  * openssl:x86-windows
  * websocketpp:x86-windows
  * zlib:x86-windows
Additional packages (*) need to be exported to complete this operation.
Exporting package zlib:x86-windows...
Exporting package zlib:x86-windows... done
Exporting package openssl:x86-windows...
Exporting package openssl:x86-windows... done
Exporting package bzip2:x86-windows...
Exporting package bzip2:x86-windows... done
Exporting package boost:x86-windows...
Exporting package boost:x86-windows... done
Exporting package websocketpp:x86-windows...
Exporting package websocketpp:x86-windows... done
Exporting package cpprestsdk:x86-windows...
Exporting package cpprestsdk:x86-windows... done
Exporting package gtest:x86-windows...
Exporting package gtest:x86-windows... done
Creating zip archive...
Creating zip archive... done
zip archive exported at: C:/vcpkg/vcpkg-export-20170428-155351.zip
```

Bob takes the zip file and extracts the contents next to his other dependencies. Bob can now proceed with building his own project as before.

### ii. User has a vcpkg root that works and wants to share it
Developer Alice has been using `vcpkg` and has a Visual Studio project that consumes libraries from it (via `vcpkg integrate`). The project is built for both 32-bit and 64-bit architectures. Alice wants to quickly share the dependencies with Bob so he can test the project.
```no-highlight
> vcpkg export gtest zlib gtest:x64-windows zlib:x64-windows --nuget
The following packages are already built and will be exported:
    gtest:x86-windows
    gtest:x64-windows
    zlib:x86-windows
    zlib:x64-windows
Exporting package zlib:x86-windows...
Exporting package zlib:x86-windows... done
Exporting package zlib:x64-windows...
Exporting package zlib:x64-windows... done
Exporting package gtest:x86-windows...
Exporting package gtest:x86-windows... done
Exporting package gtest:x64-windows...
Exporting package gtest:x64-windows... done
Creating nuget package...
Creating nuget package... done
Nuget package exported at: C:/vcpkg/scripts/buildsystems/tmp/vcpkg-export-20170428-164312.nupkg
```

Alice gives to Bob: a) The link to her project and b) The NuGet package "vcpkg-export-20170428-164312.nupkg". Bob clones the project and then installs the NuGet package. Bob is now ready to build Alice's project.

### iii. User has a vcpkg root that works and wants to share it #2
Developer Alice has been using `vcpkg` and has a CMake project that consumes libraries from it (via CMake toolchain file). Alice wants to quickly share the dependencies with Bob so he can test the project.
```no-highlight
> vcpkg export cpprestsdk zlib --zip
The following packages are already built and will be exported:
  * boost:x86-windows
  * bzip2:x86-windows
    cpprestsdk:x86-windows
  * openssl:x86-windows
  * websocketpp:x86-windows
    zlib:x86-windows
Additional packages (*) need to be exported to complete this operation.
Exporting package zlib:x86-windows...
Exporting package zlib:x86-windows... done
Exporting package openssl:x86-windows...
Exporting package openssl:x86-windows... done
Exporting package bzip2:x86-windows...
Exporting package bzip2:x86-windows... done
Exporting package boost:x86-windows...
Exporting package boost:x86-windows... done
Exporting package websocketpp:x86-windows...
Exporting package websocketpp:x86-windows... done
Exporting package cpprestsdk:x86-windows...
Exporting package cpprestsdk:x86-windows... done
Creating zip archive...
Creating zip archive... done
zip archive exported at: C:/vcpkg/vcpkg-export-20170428-155351.zip
```

Alice gives to Bob: a) The links to her project and b) The zip file "vcpkg-export-20170428-155351.zip". Bob clones the project, extracts the zip file and uses the provided (in the zip) CMake toolchain file to make the dependencies available to CMake. Bob is now ready to build Alice's project.

## 5. Technical model

- Each exported library, must be accompanied with all of its dependencies, even if they are not explicitly specified in the `vcpkg export` command.
- When exporting a library, a dependency graph will be built, similarly to install, to figure out which packages need to be exported.
- It is allowed to have packages from different triplets, so users can include 32/64-bit and dynamic/static binaries in the same export.
- The exported archives also include the files needed to integrate with MSBuild and/or CMake.