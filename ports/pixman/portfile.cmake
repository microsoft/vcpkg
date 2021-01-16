if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Meson is not able to automatically export symbols for DLLs
    # Insert in the beginning to make it overwriteable
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        list(INSERT VCPKG_CXX_FLAGS 0 /arch:SSE2)
        list(INSERT VCPKG_C_FLAGS 0 /arch:SSE2)
    endif()
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(INSERT VCPKG_CXX_FLAGS 0 /arch:SSE2)
    list(INSERT VCPKG_C_FLAGS 0 /arch:SSE2)
    list(APPEND OPTIONS
            -Dmmx=enabled
            -Dsse2=enabled
            -Dssse3=enabled)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    list(APPEND OPTIONS
            -Dmmx=enabled
            -Dsse2=enabled
            -Dssse3=enabled)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND OPTIONS
            -Darm-simd=enabled
        )
endif()

set(PIXMAN_VERSION 0.40.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/pixman-${PIXMAN_VERSION}.tar.gz"
    FILENAME "pixman-${PIXMAN_VERSION}.tar.gz"
    SHA512 063776e132f5d59a6d3f94497da41d6fc1c7dca0d269149c78247f0e0d7f520a25208d908cf5e421d1564889a91da44267b12d61c0bd7934cd54261729a7de5f
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PIXMAN_VERSION}
)
# Meson install wrongly pkgconfig file!
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
            -Dlibpng=enabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
