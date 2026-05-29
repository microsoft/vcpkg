vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-libs/fmem
    REF 2ccee3d2fb2fc72370a9bb2131bfc9167e0d9022
    SHA512 4a63332eb5df7f30bdad9e4233171b5c21dd2b092e525e9dcc4f602295ffff50c555c80fd74d964bc3daeffd8001a9b852f1769ef3161259dd8a3cae3ca3a4df
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/fmem" RENAME copyright)
