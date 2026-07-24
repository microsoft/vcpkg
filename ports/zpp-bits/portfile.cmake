vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalz800/zpp_bits
    REF "v${VERSION}"
    SHA512 d06c62218f28a4c39f1e3957ae43542a8f709d5514cfc77fc685508edcba3b4f580ead715a3cb320ac017ceb14ee8e27a751e400cf73ae575452c04c5dc4ac14
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/zpp_bits.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
