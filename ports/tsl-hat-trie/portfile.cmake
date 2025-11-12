set(VCPKG_BUILD_TYPE release) # Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hat-trie
    REF "v${VERSION}"
    SHA512 24b7f2fd83f03ff30cfa186cd68b8110ee7ed40c378861de750c1c0957e3a9870dc434ee3ae184d8ce4b07687cb0ffa83e8c7ddadccd57d8e87c97ae7b066115
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/tsl" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
