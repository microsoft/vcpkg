macro(z_vcpkg_find_acquire_pkgconfig_msys_declare_packages)
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/clangarm64/mingw-w64-clang-aarch64-pkgconf-1~2.4.3-1-any.pkg.tar.zst"
        SHA512 c2bb144b71bab8d1461c1c56b3b8d0cfe47ff7afd6757cfb5b7d0e887bfa7a9d0e95789da13169f5981a8d555aa4b0a7e2acc841c5a6b06763073f74966f4239
        PROVIDES mingw-w64-clang-aarch64-pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-pkgconf-1~2.4.3-1-any.pkg.tar.zst"
        SHA512 bd7986cdf104a6e21abc27f270716cf7f93152fdb92733b23dfa0e44465b3e739e9c90a4934419198f856887f1cfe20ba1ef52478b84ea9e795f44e699475e11
        PROVIDES mingw-w64-x86_64-pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-pkgconf-1~2.4.3-1-any.pkg.tar.zst"
        SHA512 22b3f5b2b25628713cae722e351f105f7670bc8364e41fd3bf68d8c86866c273215f2c31d467657ccf0e106eedd7c207ff474173f0eaeba5f2d7130ce6a0d3db
        PROVIDES mingw-w64-i686-pkg-config
    )
endmacro()

set(program_name pkg-config)
if(DEFINED "ENV{PKG_CONFIG}")
    debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
    set(PKGCONFIG "$ENV{PKG_CONFIG}" CACHE INTERNAL "")
    set(PKGCONFIG "${PKGCONFIG}" PARENT_SCOPE)
    return()
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "OpenBSD")
    # As of 6.8, the OpenBSD specific pkg-config doesn't support {pcfiledir}
    set(rename_binary_to "pkg-config")
    set(program_version 0.29.2.1)
    set(raw_executable ON)
    set(download_filename "pkg-config.openbsd")
    set(tool_subdirectory "openbsd")
    set(download_urls "https://raw.githubusercontent.com/jgilje/pkg-config-openbsd/master/pkg-config")
    set(download_sha512 b7ec9017b445e00ae1377e36e774cf3f5194ab262595840b449832707d11e443a102675f66d8b7e8b2e2f28cebd6e256835507b1e0c69644cc9febab8285080b)
    set(version_command --version)
elseif(CMAKE_HOST_WIN32)
    if(NOT EXISTS "${PKGCONFIG}")
        set(program_version 2.1.0)
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(host_arch "$ENV{PROCESSOR_ARCHITEW6432}")
        else()
            set(host_arch "$ENV{PROCESSOR_ARCHITECTURE}")
        endif()

        if("${host_arch}" STREQUAL "ARM64")
            vcpkg_acquire_msys(PKGCONFIG_ROOT
                NO_DEFAULT_PACKAGES
                Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_acquire_pkgconfig_msys_declare_packages"
                PACKAGES mingw-w64-clang-aarch64-pkgconf
            )
            set("${program}" "${PKGCONFIG_ROOT}/clangarm64/bin/pkg-config.exe" CACHE INTERNAL "")
        elseif("${host_arch}" MATCHES "64")
            vcpkg_acquire_msys(PKGCONFIG_ROOT
                NO_DEFAULT_PACKAGES
                Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_acquire_pkgconfig_msys_declare_packages"
                PACKAGES mingw-w64-x86_64-pkgconf
            )
            set("${program}" "${PKGCONFIG_ROOT}/mingw64/bin/pkg-config.exe" CACHE INTERNAL "")
        else()
            vcpkg_acquire_msys(PKGCONFIG_ROOT
                NO_DEFAULT_PACKAGES
                Z_DECLARE_EXTRA_PACKAGES_COMMAND "z_vcpkg_find_acquire_pkgconfig_msys_declare_packages"
                PACKAGES mingw-w64-i686-pkgconf
            )
            set("${program}" "${PKGCONFIG_ROOT}/mingw32/bin/pkg-config.exe" CACHE INTERNAL "")
        endif()
    endif()
    set("${program}" "${${program}}" PARENT_SCOPE)
    return()
else()
    set(brew_package_name pkg-config)
    set(apt_package_name pkg-config)
    set(paths_to_search "/bin" "/usr/bin" "/usr/local/bin")
    if(VCPKG_HOST_IS_OSX)
        vcpkg_list(PREPEND paths_to_search "/opt/homebrew/bin")
    endif()
endif()
