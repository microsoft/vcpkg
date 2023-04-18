set(program_name pkg-config)
if(DEFINED ENV{PKG_CONFIG})
    debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
    set(PKGCONFIG "$ENV{PKG_CONFIG}" CACHE INTERNAL "")
    set(PKGCONFIG "${PKGCONFIG}" PARENT_SCOPE)
    return()
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "OpenBSD")
    # As of 6.8, the OpenBSD specific pkg-config doesn't support {pcfiledir}
    set(supported_on_unix ON)
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
        set(VERSION 0.29.2-3)
        set(program_version git-9.0.0.6373.5be8fcd83-1)
        vcpkg_acquire_msys(
            PKGCONFIG_ROOT
            NO_DEFAULT_PACKAGES
            DIRECT_PACKAGES
                "https://repo.msys2.org/mingw/i686/mingw-w64-i686-pkg-config-${VERSION}-any.pkg.tar.zst"
                0c086bf306b6a18988cc982b3c3828c4d922a1b60fd24e17c3bead4e296ee6de48ce148bc6f9214af98be6a86cb39c37003d2dcb6561800fdf7d0d1028cf73a4
                "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-${program_version}-any.pkg.tar.zst"
                c89c27b5afe4cf5fdaaa354544f070c45ace5e9d2f2ebb4b956a148f61681f050e67976894e6f52e42e708dadbf730fee176ac9add3c9864c21249034c342810
        )
    endif()
    set("${program}" "${PKGCONFIG_ROOT}/mingw32/bin/pkg-config.exe" CACHE INTERNAL "")
    set("${program}" "${${program}}" PARENT_SCOPE)
    return()
else()
    set(brew_package_name pkg-config)
    set(apt_package_name pkg-config)
    set(paths_to_search "/bin" "/usr/bin" "/usr/local/bin")
endif()
