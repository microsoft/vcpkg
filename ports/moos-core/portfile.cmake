vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/core-moos
    REF v10.4.0
    SHA512 8a82074bd219bbedbe56c2187afe74a55a252b0654a675c64d1f75e62353b0874e7b405d9f677fadb297e955d11aea50a07e8f5f3546be3c4ddab76fe356a51e
    HEAD_REF master
    PATCHES
        cmake_fix.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools ENABLE_TOOLS
        db    ENABLE_DB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DENABLE_DOXYGEN=OFF
        -DUPDATE_GIT_VERSION_INFO=OFF
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MOOS)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES atm gtm ktm mqos mtm umm AUTO_CLEAN)
endif()
if("db" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES MOOSDB AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/Core/GPLCore.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
