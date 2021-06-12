vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/daw_json_link
    REF v2.9.5
    SHA512 cc4581fe93455e5ecf72cabbcc54a580f5fae733aa1cacbf6feb83cf75a8cf0b1d6565aa386fbb537207fc87eabe5a4b4e3b535cdecbbef2d49329eda7866fad
    HEAD_REF release
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DDAW_ENABLE_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/daw_header_libraries DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/daw_utf_range)
vcpkg_cmake_config_fixup(CONFIG_PATH share/json_link/cmake$)
vcpkg_cmake_config_fixup(CONFIG_PATH share/json_link/cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/share/json_link
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
