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
        set(program_version 1.8.0)
        if("$ENV{PROCESSOR_ARCHITECTURE}" STREQUAL "ARM64")
            vcpkg_acquire_msys(PKGCONFIG_ROOT
                NO_DEFAULT_PACKAGES
                DIRECT_PACKAGES
                    "https://mirror.msys2.org/mingw/clangarm64/mingw-w64-clang-aarch64-pkgconf-1~1.8.0-2-any.pkg.tar.zst"
                    f682bbeb4588a169a26d3c9c1ce258c0022954fa11a64e05cd803bcbb8c4e2442022c0c6bc7e54d3324359c80ea67904187d4cb3b682914f5f14a03251daae7c
            )
            set("${program}" "${PKGCONFIG_ROOT}/clangarm64/bin/pkg-config.exe" CACHE INTERNAL "")
        else()
            vcpkg_acquire_msys(PKGCONFIG_ROOT
                NO_DEFAULT_PACKAGES
                DIRECT_PACKAGES
                    "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-pkgconf-1~1.8.0-2-any.pkg.tar.zst"
                    e5217d9c55ede4c15706b4873761cc6e987eabc1308120a3e8406571ae2993907f3776f2b2bba18d7aaec80ef97227696058cedc1b67a773530dc1e6077b95e6
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
endif()
