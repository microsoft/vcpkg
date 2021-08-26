vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF 0380370f0626de2ad0ec7ea815803e22bbf6b42e
    SHA512 47df2a291febf0565787ed9c4222ee1958d03c5b76c54923e4d8e44f75321c266e81d69ba4512a4ab07d7e431c065d025e01269cf9c1d5f0927f133885def4c7
    HEAD_REF master
    PATCHES
        fix-vm-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLAZE_SMP_THREADS=OpenMP
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/blaze/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
