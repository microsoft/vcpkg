vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF af6b7652117fbdb12c9f330570e8463e00058870 # 1.7.1
    SHA512 5e8a80de17f0c0e7fe6273d180d8736c08332e4a63a474cb052eb7eee3481c046bd587a13c4763dddb0f57e71a9eb673d3e68ce0d9107dd65c2050d6436bf6b0
    HEAD_REF master
    PATCHES
        0001-win32_compiler_options.cmake.patch
        0002-no-source-dir-writes.patch
        0003-fix-copy-vendor.patch
        fix-dependency.patch
        use-vcpkg-boost.patch
        fix-unix-compiler-options.patch
        fix-CPL_DLL.patch
        0004-fix-const-overloaded.patch
)

file(REMOVE "${SOURCE_PATH}/pdal/gitsha.cpp")

# Prefer pristine CMake find modules + wrappers and config files from vcpkg.
foreach(package IN ITEMS Curl GDAL GEOS GeoTIFF ICONV PostgreSQL)
    file(REMOVE "${SOURCE_PATH}/cmake/modules/Find${package}.cmake")
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" VCPKG_BUILD_STATIC_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPDAL_BUILD_STATIC:BOOL=${VCPKG_BUILD_STATIC_LIBS}
        -DWITH_TESTS:BOOL=OFF
        -DWITH_COMPLETION:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/pdal/cmake)
vcpkg_copy_pdbs()

# Install and cleanup executables
file(GLOB pdal_unsupported
    "${CURRENT_PACKAGES_DIR}/bin/*.bat"
    "${CURRENT_PACKAGES_DIR}/bin/pdal-config"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*.bat"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
    "${CURRENT_PACKAGES_DIR}/debug/bin/pdal-config"
)
file(REMOVE ${pdal_unsupported})
vcpkg_copy_tools(TOOL_NAMES pdal AUTO_CLEAN)

# Post-install clean-up
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib/pdal"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pdal"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
