vcpkg (0.0.40)
--------------
  * Add ports:
    - ace 6.4.0
    - asio 1.10.6
    - bond 5.0.0
    - constexpr 1.0
    - doctest 1.1.0
    - eigen3 3.2.9
    - fmt 3.0.0
    - gflags 2.1.2
    - glm 0.9.8.1
    - grpc 1.1.0
    - gsl 0-fd5ad87bf
    - gtest 1.8
    - libiconv 1.14
    - mpir 2.7.2
    - protobuf 3.0.2
    - ragel 6.9
    - rapidxml 1.13
    - sery 1.0.0
    - stb 1.0
  * Update ports:
    - boost 1.62
    - glfw3 3.2.1
    - opencv 3.1.0-1
  * Various fixes in existing portfiles
  * Introduce environment variable `VCPKG_DEFAULT_TRIPLET`
  * Replace everything concerning MD5 with SHA512
  * Add mirror support
  * `vcpkg` now checks for valid package names: only ASCII lowercase chars, digits, or dashes are allowed
  * `vcpkg create` now also creates a templated CONTROL file
  * `vcpkg create` now checks for invalid chars in the zip path  
  * `vcpkg edit` now throws an error if it cannot launch an editor
  * Fix `vcpkg integrate` to only apply to C++ projects instead of all projects
  * Fix `vcpkg integrate` locale-specific failures
  * `vcpkg search` now does simple substring searching
  * Fix path that assumed Visual Studio is installed in default location
  * Enable multicore builds by default
  * Add `.vcpkg-root` file to detect the root directory
  * Fix `bootstrap.ps1` to work with older versions of powershell
  * Add `SOURCE_PATH` variable to all portfiles.
  * Many improvements in error messages shown by `vcpkg`
  * Various updates in FAQ
  * Move `CONTRIBUTING.md` to root

-- vcpkg team <vcpkg@microsoft.com>  WED, 05 Oct 2016 17:00:00 -0700


vcpkg (0.0.30)
--------------
  * DLLs are now accompanied with their corresponding PDBs.
  * Rework removal commands. `vcpkg remove <pkg>` now uninstalls the package. `vcpkg remove --purge <pkg>` now uninstalls and also deletes the package.
  * Rename option --arch to --triplet.
  * Extensively rework directory tree layout to make it more intuitive.
  * Improve post-build verification checks.
  * Improve post-build verification messages; they are now more compact, more consistent and contain more suggestions on how to resolve the issues found.
  * Fix `vcpkg integrate project` in cases where the path contained non-alphanumeric chars.
  * Improve handling of paths. In general, commands with whitespace and non-ascii characters should be handled better now.
  * Add colorized output for `vcpkg clean` and `vcpkg purge`.
  * Add colorized output for many more errors.
  * Improved `vcpkg update` to identify installed libraries that are out of sync with their portfiles.
  * Added list of example port files to EXAMPLES.md
  * Rename common CMake utilities to use prefix `vcpkg_`.
  * [libpng] Fixed x86-uwp and x64-uwp builds.
  * [libjpeg-turbo] Fixed x86-uwp and x64-uwp builds via suppressing static CRT linkage.
  * [rapidjson] New library.

-- vcpkg team <vcpkg@microsoft.com>  WED, 18 Sep 2016 20:50:00 -0700
