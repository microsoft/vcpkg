vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO minio/minio-cpp
    REF 0847e56f31e13d32c924029d5ffaa865f8396462
    SHA512 47817c8acc92060afca5ebd7c9bc7c9a9e09a50046180d7d3d67993f207d295c90e491417702ebb1ab2b0a6e85a5fcc334054ce4f6d542cb42c3675b5aed1c3f
    HEAD_REF main
    PATCHES
        fix_cmake_file.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
