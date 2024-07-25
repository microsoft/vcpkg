vcpkg_buildpath_length_warning(37)

# See https://github.com/ompl/ompl/blob/main/src/ompl/CMakeLists.txt#L49-L54
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ompl/ompl
    REF "${VERSION}"
    SHA512 d1024d7cc8e309a1df94a950be67eefae1e66abaccd6b6b8980939559aee3d73c05c838ab24c818b6b57ce6c4b3181fde7595d3d1dd36d6cd0c6d125338084ac
    HEAD_REF master
    PATCHES
        0001_Export_targets.patch
        0002_Fix_config.patch
        0003_fix_dep.patch
)

# Based on selected features different files get downloaded, so use the following command instead of patch.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "find_package(Eigen3 REQUIRED)" "find_package(Eigen3 REQUIRED CONFIG)")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "find_package(ccd REQUIRED)" "find_package(ccd REQUIRED CONFIG)" IGNORE_UNCHANGED)

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
