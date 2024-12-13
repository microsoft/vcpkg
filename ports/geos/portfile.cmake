vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/geos/geos-${VERSION}.tar.bz2"
    FILENAME "geos-${VERSION}.tar.bz2"
    SHA512 8ffaa3f49a8365db693ac948e9d66cf55321eb12151734c7da2775070b7804ffa607de2474b7019d6ea2a99d5e037fb1e8561bf9025e65ddd4bd1ba049382b28
)
vcpkg_download_distfile(msvc_2017_patch
    URLS https://github.com/libgeos/geos/commit/46e9f158073ebf0d4ec8b7dde37c155d097bc0d7.diff?full_index=1
    SHA512 9fa1ccc4c66e8268c59bcac218015c2b10ee594bece837e6d0fc78fe700233abd1b2df7aa396c00786ffb170fbfbb0ab530f5007ba10376a2366ee3472d8b02a
    FILENAME geos-${VERSION}-msvc-2017.diff
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        fix-exported-config.patch
        "${msvc_2017_patch}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_ASTYLE=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_GEOSOP=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/GEOS)
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/geos-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/geos-config")
    file(CHMOD "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/geos-config" FILE_PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
    )
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/geos-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/geos-config")
        file(CHMOD "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/geos-config" FILE_PERMISSIONS
            OWNER_READ OWNER_WRITE OWNER_EXECUTE
            GROUP_READ GROUP_EXECUTE
            WORLD_READ WORLD_EXECUTE
        )
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
