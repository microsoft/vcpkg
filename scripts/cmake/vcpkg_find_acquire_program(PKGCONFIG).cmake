macro(z_vcpkg_find_acquire_pkgconfig_msys_declare_packages)
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/clangarm64/mingw-w64-clang-aarch64-pkgconf-1~3.0.7-1-any.pkg.tar.zst"
        SHA512 55858bc65e3be564a43ac255f8c1fec4586a51afcba2cb0aba528c9909aa530a0f3d257de537d1c316b2695e86cbfd568fccb312f0bd91a4623c7cdbf4295220
        PROVIDES mingw-w64-clang-aarch64-pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw64/mingw-w64-x86_64-pkgconf-1~3.0.7-1-any.pkg.tar.zst"
        SHA512 27a88825f334d8fe2477f193eaa30785f3b79aa03e07f5793611fe29c9b7dc552338216a4a1f24d2801a467dd453295c077fa07a9c6b83b882afd6bb3928ddec
        PROVIDES mingw-w64-x86_64-pkg-config
    )
    z_vcpkg_acquire_msys_declare_package(
        URL "https://mirror.msys2.org/mingw/mingw32/mingw-w64-i686-pkgconf-1~3.0.7-1-any.pkg.tar.zst"
        SHA512 a9a39bd4f4efd1d15f48ab9a1ea50b5eee7a56496bb187d792fb76e93181797e3803e6e78b8e8a1ec376020a8d2bdb6a4fb7db7dbccc88c8a1eea669cc39a1b4
        PROVIDES mingw-w64-i686-pkg-config
    )
endmacro()

set(program_name pkg-config)
if(DEFINED "ENV{PKG_CONFIG}")
    debug_message(STATUS "PKG_CONFIG found in ENV! Using $ENV{PKG_CONFIG}")
    set(PKGCONFIG "$ENV{PKG_CONFIG}" CACHE INTERNAL "")
    set(PKGCONFIG "${PKGCONFIG}" PARENT_SCOPE)
    return()
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
