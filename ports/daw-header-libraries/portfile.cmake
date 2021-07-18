vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/header_libraries
    REF 2fb3c668d90a3eb4158de40daf18a860c6eb3115
    SHA512 ae4f1c8fa5c2ca5e0fe7e21ba0f43cf42d746a324b69c8de5bbc2c89d7dd5f31f76302a9f713ac51533df2ace703e20b35291e30577449df1565f6a3e14ab659
    HEAD_REF master
    PATCHES rename_port.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DDAW_ENABLE_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
