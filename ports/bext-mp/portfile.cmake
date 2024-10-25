vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qlibs/mp
    REF "v${VERSION}"
    SHA512 101978e93e8a4ec095263ce3c45bdae2b599cf98b239dabb6823679578784f64860bc5eacfc8f908fc1669d7b5391b49e3df0bb2037e0463fc89e2ee781bf3d2
    HEAD_REF main
    PATCHES add-LICENSE.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

file(COPY "${SOURCE_PATH}/mp"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
