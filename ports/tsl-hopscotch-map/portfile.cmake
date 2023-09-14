vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/hopscotch-map
    REF 29030f55ca518bb1be5113ab0a8e134772024a9d # v2.3.0
    SHA512 944f26fe0faa59b799ddf741c4f86b715934e740bfbb40a157f667eaff07013a35ad40a343b720b36279acefbb5b206a54cfcfec1f6cd052314936d19e5da413
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright
)
