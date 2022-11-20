set(GEOS_VERSION 3.11.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2"
    FILENAME "geos-${GEOS_VERSION}.tar.bz2"
    SHA512 40c7553bbb93673c231ddd0131b73bf43b3f50524bc5bd9e6934c068d2c09632f388b7429254ae15d9641da2d15e3a626b430438854e98d9e7419ad04e535189
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF "${GEOS_VERSION}"
    PATCHES
        disable-warning-4996.patch
        fix-exported-config.patch
        fix_clang-cl.patch
)

vcpkg_list(SET EXTRA_OPTIONS)
if(VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND EXTRA_OPTIONS "-DDISABLE_GEOS_INLINE=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_ASTYLE=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_GEOSOP=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKS=OFF
        ${EXTRA_OPTIONS}
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
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
