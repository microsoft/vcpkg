vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO snitch-org/snitch
    REF "v${VERSION}"
    SHA512 c94f04967ed94fb697c72eb87c29f6c34fed3538704d21855d6617a44ca96c1ea3b59a739e545a3f7cb60b58e930486929f551c5db09ae47fbdd45dcd5bf9455
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSNITCH_DEFINE_MAIN=0
        -DCMAKE_CXX_STANDARD=20
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/snitch
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
