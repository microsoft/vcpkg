vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/ctus
    REF ${VERSION}
    SHA512 28c930364e4bb207bd336139d570287a467c55fab9ef91bb546330ca5ed106986b4eaadb31e956dc5e4c2ded9a49917e0a5775e0ad157cddb0bf56a2afb3b150
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ctus CONFIG_PATH lib/cmake/ctus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")