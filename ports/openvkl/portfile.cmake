vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  openvkl/openvkl
    REF 0f55eebd89842183ec02c17cee8a1b759c2552ac
    SHA512 87dcb6bd48691d9232af015a96a815c0fd8ab76b371071d21e9d95f68321f6b56efd3c6635c4bc21845eec1de0ef56453f0c567da07d4c61b7d85532f504d52f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        "-DISPC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/ispc/bin/ispc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}-${VERSION}")


#vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
