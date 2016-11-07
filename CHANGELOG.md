vcpkg (0.0.50)
--------------
  * Add ports:
    - apr                  1.5.2
    - assimp               3.3.1
    - boost-di             1.0.1
    - bullet3              2.83.7.98d4780
    - catch                1.5.7
    - chakracore           1.2.0.0
    - cppwinrt             1.010.0.14393.0
    - cppzmq               0.0.0-1
    - cryptopp             5.6.5
    - double-conversion    2.0.1
    - dxut                 11.14
    - fastlz               1.0
    - freeglut             3.0.0
    - geos                 3.5.0
    - gettext              0.19
    - glbinding            2.1.1
    - glog                 0.3.4-0472b91
    - harfbuzz             1.3.2
    - jxrlib               1.1
    - libbson              1.4.2
    - libccd               2.0.0
    - libmariadb           2.3.1
    - libmysql             5.7.16
    - libodb               2.4.0
    - libodb-sqlite        2.4.0
    - libogg               1.3.2
    - libraw               0.17.2
    - libtheora            1.1.1
    - libvorbis
    - libwebp              0.5.1
    - libxml2              2.9.4
    - log4cplus            1.1.3-RC7
    - lua                  5.3.3
    - mongo-c-driver       1.4.2
    - mongo-cxx-driver     3.0.2
    - nanodbc              2.12.4
    - openjpeg             2.1.2
    - pcre                 8.38
    - pdcurses             3.4
    - physfs               2.0.3
    - rxcpp                2.3.0
    - spdlog               0.11.0
    - tbb                  20160916
    - think-cell-range     1d785d9
    - utfcpp               2.3.4
    - wt                   3.3.6
    - wtl                  9.1
    - zeromq               4.2.0
    - zziplib              0.13.62
  * Update ports:
    - boost                1.62             -> 1.62-1
    - cpprestsdk           2.8              -> 2.9.0-1
    - curl                 7.48.0           -> 7.51.0
    - eigen3               3.2.9            -> 3.2.10-2
    - freetype             2.6.3            -> 2.6.3-1
    - glew                 1.13.0           -> 2.0.0
    - openssl              1.0.2h           -> 1.0.2j
    - range-v3             0.0.0-1          -> 20150729-vcpkg2
    - sqlite3              3120200          -> 3.15.0
  * Add support for static libraries
  * Add more post build checks
  * Improve post build checks related to verifying information in the dll/pdb files (e.g. architecture)
  * Many fixes in existing portfiles
  * Various updates in FAQ
  * Release builds now create pdbs (debug builds already did)

-- vcpkg team <vcpkg@microsoft.com>  MON, 07 Nov 2016 00:01:00 -0800

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
