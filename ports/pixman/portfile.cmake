if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(VCPKG_CXX_FLAGS "/arch:SSE2 ${VCPKG_CXX_FLAGS}") # TODO: /arch: flag requires compiler check. needs to be MSVC
    set(VCPKG_C_FLAGS "/arch:SSE2 ${VCPKG_C_FLAGS}")
    list(APPEND OPTIONS
            -Dmmx=enabled
            -Dsse2=enabled
            -Dssse3=enabled)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    #x64 in general has all those intrinsics. (except for UWP for some reason)
    list(APPEND OPTIONS
            -Dmmx=enabled
            -Dsse2=enabled
            -Dssse3=enabled)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND OPTIONS
            #-Darm-simd=enabled does not work with arm64-windows
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "mips")
    list(APPEND OPTIONS
            -Dmmx=disabled
            -Dsse2=disabled
            -Dssse3=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND OPTIONS
                -Da64-neon=disabled
                -Darm-simd=disabled
                -Dneon=disabled
                )
endif()

set(PIXMAN_VERSION "${VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz"
    FILENAME "pixman-${PIXMAN_VERSION}.tar.gz"
    SHA512 0a4e327aef89c25f8cb474fbd01de834fd2a1b13fdf7db11ab72072082e45881cd16060673b59d02054b1711ae69c6e2395f6ae9214225ee7153939efcd2fa5d
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        no-host-cpu-checks.patch
        fix_clang-cl.patch
        missing_intrin_include.patch
)
# Meson install wrongly pkgconfig file!
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Dlibpng=enabled
        -Dtests=disabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
