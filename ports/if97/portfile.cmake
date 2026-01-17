vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CoolProp/IF97
    REF "v${VERSION}"
    SHA512 c8aef492445a167d76f92174edadfd37d9918a3f9ca718d63d26dc4692ade5539cbce362a92e4a5b78f3d95766baf5da36a6783cc6001bd9fad204ebe2cad44f
    HEAD_REF master
    PATCHES
        relax-encoding.diff
)

file(INSTALL "${SOURCE_PATH}/IF97.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
