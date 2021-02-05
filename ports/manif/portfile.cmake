vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artivis/manif
    REF 0.0.4
    SHA512 c6e0a333421d4bd3bf81f558bfc20b566960798281b6b95d234fa4e4e25fb323ad544876b1196aaf33fd335d61bf1a49d3fca4f3da24f417b04348b877199bec
    HEAD_REF master
    PATCHES
        cmake-fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DUSE_SYSTEM_WIDE_TL_OPTIONAL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Add the copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
