vcpkg_buildpath_length_warning(37)

# See https://github.com/ompl/ompl/blob/main/src/ompl/CMakeLists.txt#L49-L54
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(OMPL_VERSION 1.5.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/ompl
    REF 1.5.1
    SHA512 2f28d29f32f3bb03e67b29ce251e4786364847a25e3c4cf66d7663ed38dca4da71d4e03cf9ce647710d9524a3907c76c09795e77f041cb8822f695d28f5ca570
    HEAD_REF master
    PATCHES
        0001_Export_targets.patch
        0002_Fix_config.patch
)

# Based on selected features different files get downloaded, so use the following command instead of patch.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "find_package(Eigen3 REQUIRED)" "find_package(Eigen3 REQUIRED CONFIG)")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "find_package(ccd REQUIRED)" "find_package(ccd REQUIRED CONFIG)")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DOMPL_VERSIONED_INSTALL=OFF
        -DOMPL_REGISTRATION=OFF
        -DOMPL_BUILD_DEMOS=OFF
        -DOMPL_BUILD_TESTS=OFF
        -DOMPL_BUILD_PYBINDINGS=OFF
        -DOMPL_BUILD_PYTESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/ompl/cmake)
vcpkg_fixup_pkgconfig()

# Remove debug distribution and other, move ompl_benchmark to tools/ dir
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/share/ompl/demos"
    "${CURRENT_PACKAGES_DIR}/share/ompl/ompl.conf"
    "${CURRENT_PACKAGES_DIR}/share/ompl/plannerarena"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
