# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polycam/open3d
    REF 646a0ac0c1e26b5bc4b874fa7e7bf4c18054fae4
    SHA512 296c7c11c5d51da9d6816c5711778d5438b7bd75e7c7b0dc28e4bc94763cab176244d124d94aec72aab032c55374766f0f9e684ac1a73f8e111cd666798b923b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
