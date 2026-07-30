# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/ormpp
    REF "0.2.2"
    SHA512 5f40dcbc34d03a4fd6d66786f4987d13df9244700ad97fb33533b6725dfcd06b628165b4e1d2fd6076d2d3dad379154b48dbe134a09d25273b22c0f85b49022d
    HEAD_REF master
)

# Copy header files (iguana and frozen are provided as dependencies)
file(INSTALL "${SOURCE_PATH}/ormpp/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ormpp")

# Handle license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
