vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/commsdsl
    REF v4.0
    SHA512 420fd0dd30aa5530692f40e15e3a640d1ef766c642e91edc07ed182e2125043c6ade1d245ef4d549a606c372c8c5f53fea7faa14b230ff485cf24d4f13ecfbee
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMMSDSL_BUILD_APPS=ON
        -DCOMMSDSL_INSTALL_APPS=ON
        -DCOMMSDSL_INSTALL_LIBRARY=ON
        -DCOMMSDSL_INSTALL_LIBRARY_HEADERS=ON
        -DCOMMSDSL_BUILD_UNIT_TESTS=OFF
        -DCOMMSDSL_WARN_AS_ERR=OFF
        -DCOMMSDSL_WIN_ALLOW_LIBXML_BUILD=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_copy_tools(
    TOOL_NAMES commsdsl2comms commsdsl2test commsdsl2tools_qt
    AUTO_CLEAN
)

vcpkg_cmake_config_fixup(PACKAGE_NAME LibCommsdsl CONFIG_PATH lib/LibCommsdsl/cmake)
# after fixing the following dirs are empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/LibCommsdsl")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/LibCommsdsl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
