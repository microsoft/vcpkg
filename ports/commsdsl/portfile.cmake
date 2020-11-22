vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/commsdsl
    REF v3.5.3
    SHA512 f9e908f42e11e30aefe07f1b37d65545be2074758f054fb0d519e1a01f0b7060b309d2667459a5a6918a9ad9f535d0c0a0cc2cd0d4a281e78c2c48a6b8ae4a5d
    HEAD_REF master
    PATCHES
        "fix-cmake-cmakedir-path.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCOMMSDSL_TEST_BUILD_CC_PLUGIN=OFF
        -DCOMMSDSL_NO_TESTS=ON
        -DBUILD_TESTING=OFF
        -DCOMMSDSL_NO_WARN_AS_ERR=ON # remove on next version or on next version of boost
)
vcpkg_install_cmake()

vcpkg_copy_tools(
    TOOL_NAMES commsdsl2comms
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
