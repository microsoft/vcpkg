vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PDAL/PDAL
    REF 2.3.0
    SHA512 898ea54c8c8e0a9bb8aed8d7f542da5a44b02c8656273783366d711b5b3f50b547438aa1cb4d41b490d187dae7bef20fe3b6c64dcb87c06e6f4cb91a8f79ac59
    HEAD_REF master
    PATCHES
        0002-no-source-dir-writes.patch
        0003-fix-copy-vendor.patch
        fix-dependency.patch
        use-vcpkg-boost.patch
        fix-unix-compiler-options.patch
)

file(REMOVE "${SOURCE_PATH}/pdal/gitsha.cpp")

# Prefer pristine CMake find modules + wrappers and config files from vcpkg.
foreach(package IN ITEMS Curl GeoTIFF ICONV PostgreSQL)
    file(REMOVE "${SOURCE_PATH}/cmake/modules/Find${package}.cmake")
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" VCPKG_BUILD_STATIC_LIBS)

unset(ENV{OSGEO4W_HOME})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPDAL_BUILD_STATIC:BOOL=${VCPKG_BUILD_STATIC_LIBS}
        -DWITH_TESTS:BOOL=OFF
        -DWITH_COMPLETION:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PDAL)
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
    "${CURRENT_PACKAGES_DIR}/include/pdal/filters/private/csf"
    "${CURRENT_PACKAGES_DIR}/include/pdal/filters/private/miniball"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
