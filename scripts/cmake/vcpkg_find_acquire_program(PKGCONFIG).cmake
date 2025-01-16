macro(z_vcpkg_find_acquire_pkgconfig_msys_declare_packages)
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/clangarm64/mingw-w64-clang-aarch64-pkgconf-1~2.3.0-1-any.pkg.tar.zst"
        SHA512 b93698fc282f39715804cebeb624608584a0ef0755a6a4e321c4f0571586e91a39b3af580441f4895f5f524db151831a1eb6e06eb4de83f43a0db7b0c218bab0
        PROVIDES mingw-w64-clang-aarch64-pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-pkgconf-1~2.3.0-1-any.pkg.tar.zst"
        SHA512 5373f050060678166968e09a4dd8ad30324c5dc37842c3517ebc9eb7be7e09d37d2873ff9dc4831c283556b68a0776f06fa6f91d799020b04282b4a3f378a2c4
        PROVIDES mingw-w64-x86_64-pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-pkgconf-1~2.3.0-1-any.pkg.tar.zst"
        SHA512 8fc9e91dcc78a05e8d836352e91d424e7466eaacbf961fd781ff6d84aab059308942dad024e19ecfe600175241ebfb81bd4813352c3f7547d8c9bfccec962dab
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
