vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

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
        fix-find-library-suffix.patch
        no-pkgconfig-requires.patch
        no-rpath.patch
)

file(REMOVE "${SOURCE_PATH}/pdal/gitsha.cpp")
file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/pdalboost/boost" "${SOURCE_PATH}/vendor/pdalboost/libs")

# Prefer pristine CMake find modules + wrappers and config files from vcpkg.
foreach(package IN ITEMS Curl GeoTIFF ICONV PostgreSQL ZSTD)
    file(REMOVE "${SOURCE_PATH}/cmake/modules/Find${package}.cmake")
endforeach()

unset(ENV{OSGEO4W_HOME})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        draco       BUILD_PLUGIN_DRACO
        e57         BUILD_PLUGIN_E57
        hdf5        BUILD_PLUGIN_HDF
        i3s         BUILD_PLUGIN_I3S
        laszip      WITH_LASZIP
        lzma        WITH_LZMA
        pgpointcloud BUILD_PLUGIN_PGPOINTCLOUD
        zstd        WITH_ZSTD
)
if(BUILD_PLUGIN_DRACO)
    vcpkg_find_acquire_program(PKGCONFIG)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPDAL_PLUGIN_INSTALL_PATH=.
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DPOSTGRESQL_LIBRARIES=PostgreSQL::PostgreSQL
        -DWITH_TESTS:BOOL=OFF
        -DWITH_COMPLETION:BOOL=OFF
        -DWITH_LAZPERF:BOOL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Libexecinfo:BOOL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libunwind:BOOL=ON
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        POSTGRESQL_LIBRARIES
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PDAL)
vcpkg_fixup_pkgconfig()
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
