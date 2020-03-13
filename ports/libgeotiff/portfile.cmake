vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/libgeotiff
    REF 6bcf43890db46ba0b77cc011030e110d894a6690 #v1.5.1
    SHA512 1df1647566eeba2d123da4d240bd7474b4dc5e72a96a009bd02a17befa3c3807984475f08fa80e0b14e3db2743cc2f3f4078b52b01cbdfddd268c77034f98c73
    HEAD_REF master
    PATCHES
        cmakelists.patch
        geotiff-config.patch
)

# Delete FindPROJ4.cmake
file(REMOVE ${SOURCE_PATH}/libgeotiff/cmake/FindPROJ4.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/libgeotiff
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

file(INSTALL ${SOURCE_PATH}/libgeotiff/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(RENAME ${CURRENT_PACKAGES_DIR}/doc ${CURRENT_PACKAGES_DIR}/share/${PORT}/doc)
