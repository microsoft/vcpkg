set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hat-trie
    REF "v${VERSION}"
    SHA512 0775b95d10535e1596f6dc79feadecdd98d63e99d4ca492bc64fa8c5bcfe6bdb864b52ee55cba26cdad00e64c2ee857f70663d3e4ed03c33af8055fc17e8c38e
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/tsl" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
