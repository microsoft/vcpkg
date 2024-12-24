vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/x86-simd-sort
    REF "v${VERSION}"
    SHA512 8e7a1929b7234399d8ac30cd296b69efdfc0d9d03a91507f3b4e06f486b6b715199b35e0495f330c21b70165bcab48842cd7c0a887df4e6508b6151ad1dc9c2a
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
