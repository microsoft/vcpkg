vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mity/md4c
    REF 65c6c9d72cebd9a731aaa5597414ce04d9ea5de3
    SHA512 4a4971d340f44238259c97eadc08f84fec180bc24db3b4db1d997a08d11e36a47ae10a2b127fb7d149a33b326bf6bc43ab71dc664d5f6bf9ea83ca111ebcacc9
    HEAD_REF master
    PATCHES
        "cmake.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_MD2HTML_EXECUTABLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/md4c")
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
