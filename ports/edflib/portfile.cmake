vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Teuniz/EDFlib
    REF "v${VERSION}"
    SHA512 c87e18b90fcf7dd45fc927b76d25dcc9dc94965a03fad8ef2018179a23b1497179ef211b5984d025e94d7de88545d5b4215d01dff46b791f1eb574c29707d140
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
