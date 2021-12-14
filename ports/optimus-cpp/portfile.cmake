vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/optimus-cpp
    REF 0.1.0
    SHA512 387b1da32a653d2026d884749a69932ed47929afa92c66843a654735cdc7572f033bb64abd6553db24f03f9566e225f054234e1ec9ff177051aff3bb9ceea1ed
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
