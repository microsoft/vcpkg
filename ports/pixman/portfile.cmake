if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # Meson is not able to automatically export symbols for DLLs
    # Insert in the beginning to make it overwriteable
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        list(INSERT VCPKG_CXX_FLAGS 0 /arch:SSE2)
        list(INSERT VCPKG_C_FLAGS 0 /arch:SSE2)
    endif()
endif()

#if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    #list(APPEND PATCHES static.patch)
#endif()
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
    PATCHES #meson.build.patch
            #${PATCHES}
)
# Meson install wrongly pkgconfig file!
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
            -Dlibpng=enabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/pixman)

# vcpkg_configure_cmake(
    # SOURCE_PATH ${SOURCE_PATH}/pixman
    # PREFER_NINJA
# )

# vcpkg_install_cmake()

# #vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-pixman TARGET_PATH share/unofficial-pixman)

# # Copy the appropriate header files.
# file(COPY
    # "${SOURCE_PATH}/pixman/pixman.h"
    # "${SOURCE_PATH}/pixman/pixman-accessor.h"
    # "${SOURCE_PATH}/pixman/pixman-combine32.h"
    # "${SOURCE_PATH}/pixman/pixman-compiler.h"
    # "${SOURCE_PATH}/pixman/pixman-edge-imp.h"
    # "${SOURCE_PATH}/pixman/pixman-inlines.h"
    # "${SOURCE_PATH}/pixman/pixman-private.h"
    # "${SOURCE_PATH}/pixman/pixman-version.h"
    # DESTINATION ${CURRENT_PACKAGES_DIR}/include
# )

# # Handle copyright
# file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pixman)
# file(RENAME ${CURRENT_PACKAGES_DIR}/share/pixman/COPYING ${CURRENT_PACKAGES_DIR}/share/pixman/copyright)

# vcpkg_copy_pdbs()
# vcpkg_fixup_pkgconfig()

# vcpkg_test_cmake(PACKAGE_NAME unofficial-pixman)
