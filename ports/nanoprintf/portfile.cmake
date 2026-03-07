# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 08762cc2737304262e3489c2bd88750693a7bec027cdabadf00f96caa68a100d8a0069fa0fc4806cfcdf27b3849c40a3388869eb342442301851a001827971c1
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
