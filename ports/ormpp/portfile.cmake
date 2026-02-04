# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/ormpp
    REF "0.2.0"
    SHA512 69b41091653341a158b929004bb00b1aed909ddd12593a8dc7a2a7dc0f1b8d1a3b5716db17ffefe7134452cf997502750e1fc86ffd185f43ceb5e2d99e8ddcc5
    HEAD_REF master
)

# Copy header files (iguana and frozen are provided as dependencies)
file(INSTALL "${SOURCE_PATH}/ormpp/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ormpp")

# Handle license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
