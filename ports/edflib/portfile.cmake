vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Teuniz/EDFlib
    REF e5083444be5e7b20aaadab4578dcbb7371a69745
    SHA512 1c983937f97adb5d8c253c0d3382615c1ca4d8049ee6767cacf82420144380e9d6553cd5e73db23568a1098c8613b899982ae272ef218d303d7ea71f24b857ee
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/edflib.h"
        "#if defined(EDFLIB_SO_DLL)"
        "#if 1 // defined(EDFLIB_SO_DLL)"
    )
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-EDFlib)

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            sine_generator
            sweep_generator
        AUTO_CLEAN
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
