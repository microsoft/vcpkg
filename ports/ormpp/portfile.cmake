# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/ormpp
    REF "0.2.1"
    SHA512 131f23f3fa4ec03d4d8b1a971611dc025519fdddbd45d53822b232a83bcfee9d39192566cfa578b9d7be64ae32ac62ad1ef941cb214fe21843621a23b6dac689
    HEAD_REF master
)

# Copy header files (iguana and frozen are provided as dependencies)
file(INSTALL "${SOURCE_PATH}/ormpp/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/ormpp")

# Handle license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
