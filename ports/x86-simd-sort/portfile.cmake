vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numpy/x86-simd-sort
    REF "v${VERSION}"
    SHA512 de217d35a98da3b269454eaa8a2880b9aa36e4906670d0434799a45a8dcbe6d3fdf56cb16b683be510e34e0636b035e9de88a7b6e68b41e1eecceb5ecac4fe4a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" PATTERN "README.md" EXCLUDE)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
