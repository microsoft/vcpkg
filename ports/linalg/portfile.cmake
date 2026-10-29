#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sgorsten/linalg
    REF "v${VERSION}"
    SHA512 736f6ff83fcc4a772ef5ab8e574b0e56aca9fcf2318d92f56f94684ffbd7283540b6496381d52834545b4902147bc67a3afa21ab877bc44bba84471c2eff6862
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/linalg.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/UNLICENSE")
