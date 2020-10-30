vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/commsdsl
    REF v3.5.2
    SHA512 cc763420e84faa7f0c6bf6c7e89e21cbf4e61eeed9916273a5117786a4d54ccc58356904266b6f8e1643fdb7715deabcea868e6a7af574a44ca0363574602aa2
    HEAD_REF master
    PATCHES 
        "use-FindPackage.patch"
        "fix-libxml2.patch"
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
