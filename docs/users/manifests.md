# Manifest Mode

vcpkg has two modes of operation - classic mode and manifest mode.

Classic mode is the original mode that vcpkg had, and it acts a lot like brew,
or apt. Unlike these package management tools, however,
vcpkg installs the packages into the vcpkg installation directory,
as opposed to a global install.

Manifest mode is the new mode that vcpkg can run in;
it acts more like modern language package managers like cargo or npm.
In other words, you have a manifest file where you write your project's dependencies,
and vcpkg installs the dependencies into the project's directory.
The support for these manifests is still unstable for now,
but you _can_ use it from the CMake integration, and that should be mostly stable.
That's the recommended way to use this new mode.

Check out the [manifest cmake example](../examples/manifest-mode-cmake.md) for an example project.
