vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 55757e4a02b680b8eae9e72073bd5612ba7e167bb82c40e89a3e27e3be520b1cd6db11dbb89bfaa4b046ba5b0dab11e02f481cbf93faebc96afc34ab49cd737a
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
