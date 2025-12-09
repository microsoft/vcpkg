vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Teuniz/EDFlib
    REF "v${VERSION}"
    SHA512 ad5f9be5a10d0e83a80242cdb088db8ae697ee6e723a7c5459cef95b5eba16c54d8bc2493b66d5114a8d1782505b2d2c63c9a5ce96c09dcca89489cd43fa6012
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
