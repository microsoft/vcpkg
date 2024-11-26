vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO magiblot/tvision
    REF 966226d643cd638fb516b621ac90a31f3ec8d1f6
    HEAD_REF master
    SHA512 b18a466cad2edebff62f6db6d5ab6b6b4d000fbc0fcc682f169efd9c0cc7efe5f0535ffa019f9dcb3d6e7931f77c476ec5d11aa7b39ed7ce0417ceec270f2d36
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTV_BUILD_EXAMPLES=OFF
        -DTV_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
