vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pyomeca/ezc3d
    REF "Release_${VERSION}"
    SHA512 19f2602be04ea4b0d65d7c26cc6b5c687f65ef5bceae104d7bcddec1e8db05cc65db2cb37ac8133b7bbda99cd097ead08fd7dcdaf470f710f5cc68cd73edb150
    HEAD_REF dev
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-Dezc3d_BIN_FOLDER=bin"
        "-Dezc3d_LIB_FOLDER=lib"
        -DBUILD_EXAMPLE=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ezc3d")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
