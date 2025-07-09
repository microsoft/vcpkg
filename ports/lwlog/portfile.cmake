vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ChristianPanov/lwlog
    REF "v${VERSION}"
    SHA512 e4332bdb04617ebd38efd19367290ed69d36f6ed1d9c61a907f0639b5a58feaba715f807286291a923482d935eba971afa8db000d0b70611c1f97bf541c6229e
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME lwlog_lib CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
