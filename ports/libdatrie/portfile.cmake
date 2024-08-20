set(LIBDATRIE_VERSION 0.2.13)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tlwg/libdatrie
    REF v${LIBDATRIE_VERSION}
    SHA512 38f5a3ee1f3ca0f0601a5fcfeec3892cb34857d4b4720b8e018ca1beb6520c4c10af3bd2f0e4d64367cb256e8e2bca4d0a59b1c81fb36782613d2c258b64df59
    HEAD_REF master
    PATCHES
        fix-exports.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
       tool     SKIP_TOOL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERSION=${LIBDATRIE_VERSION}
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DSKIP_TOOL=ON
        -DSKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(NOT SKIP_TOOL)
    vcpkg_copy_tools(TOOL_NAMES trietool AUTO_CLEAN)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
