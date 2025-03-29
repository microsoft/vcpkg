vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lionkor/commandline
    REF v${VERSION}
    SHA512 c7b4cdafae55d5916e527e39a9186a4d15cbb7f65f39a23b149c5f9466dbf55ee947541c4abeabf6949425b8823076d540209112ec2509cd1e6ab583ce6fcfba
    HEAD_REF master
    PATCHES
        add-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
