vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 6c82f140b6092114ada23f216a4d2d0299a6cd422069f8660db98bca9b1bb515dfba818dae1b8ca4fadedaa6fa8f3ef98da0e8c50ee2ea2884f559c8a0db5fd1
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
