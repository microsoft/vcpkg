vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 b5df44cb9eaafb1926e6acc795e47673d84206da3e33c5b863fedddee56f5c10b45e1b4b33fe0ee6ca64dab68d44c7b3c981cd04482b7c30e4342f45f6d4258c
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
