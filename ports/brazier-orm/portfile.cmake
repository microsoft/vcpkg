vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier-orm
    REF "v${VERSION}"
    SHA512 551423a68e30d2840f346e9e24367f0e6332070b4aa63a4925f1877ee1f26a7802ce386d110b3f24366900b7b71faf87e7f68ccd99a37ff33d6c27da8da8c4b2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/brazier-orm"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")
