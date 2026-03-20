vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 faa96f9702a96fae10ba9dec01d0eda0e708a8bda2ee9febbcca89dfe78cf4947edbff941fe51c5529ad4c76a344ea187069ba3ed79daa36140cf39acfb522b8
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
