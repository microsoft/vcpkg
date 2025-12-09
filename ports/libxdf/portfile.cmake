vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xdf-modules/libxdf
    REF "v${VERSION}"
    SHA512 17b68a307118a1a1375ad1a4717d5bd83515daea51623f617d0c5673435fb79df2bbc7445504b274495481b089f93b10bec025a05ef641478eff77e36d420e4c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXDF_NO_SYSTEM_PUGIXML=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
