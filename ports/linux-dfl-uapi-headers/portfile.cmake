vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OFS/linux-dfl-backport
    REF "${VERSION}"
    SHA512 b32bd170853e69f95748c041a61809d947de40a0ba9b97f528c5878e427e49f631aee056e838d95191cbfe183f602a081ebd966dc6f52aae029302dfbdf04499
    HEAD_REF intel/fpga-ofs-dev-6.6-lts
)

file(INSTALL "${SOURCE_PATH}/include/uapi/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/uapi")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
