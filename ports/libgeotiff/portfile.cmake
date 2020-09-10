vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/libgeotiff
    REF  8b1a8f52bc909f86e04ceadd699db102208074a2 #v1.6.0
    SHA512 41715d6a416307a93b2f95874c00ed27c3a0450d70311e77ed45f7ff477bd85f4a69b549bde01dfb9412a62a482467222fc8ed398478e2829e4d112012aab852
    HEAD_REF master
    PATCHES
        cmakelists.patch
        geotiff-config.patch
        fix-proj4.patch
)

set(SOURCE_PATH ${SOURCE_PATH}/libgeotiff)

# Delete FindPROJ4.cmake
file(REMOVE ${SOURCE_PATH}/cmake/FindPROJ4.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_TIFF=1
        -DWITH_PROJ4=1
        -DWITH_ZLIB=1
        -DWITH_JPEG=1
        -DWITH_UTILITIES=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/doc)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(GLOB GEOTIFF_UTILS ${CURRENT_PACKAGES_DIR}/bin/*)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB GEOTIFF_UTILS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(GLOB GEOTIFF_UTILS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${GEOTIFF_UTILS_DEBUG})
endif()

file(COPY ${GEOTIFF_UTILS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/libgeotiff)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/libgeotiff)
file(REMOVE ${GEOTIFF_UTILS})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/GeoTIFF)

file(INSTALL ${CURRENT_PACKAGES_DIR}/share/${PORT}/geotiff-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/${PORT}/geotiff-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/${PORT}/geotiff-depends-release.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/${PORT}/geotiff-depends-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(INSTALL ${CURRENT_PACKAGES_DIR}/share/${PORT}/geotiff-depends.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/geotiff)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(RENAME ${CURRENT_PACKAGES_DIR}/doc ${CURRENT_PACKAGES_DIR}/share/${PORT}/doc)
