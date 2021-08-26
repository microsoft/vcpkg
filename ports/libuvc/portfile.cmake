vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libuvc/libuvc
    REF c612d4509eb0ff19ce414abc3dca18d0f6263a84
    SHA512 df3f23463728e8ffd69dc52e251ea2610ea8df32b02f6d26dd2a6910cf217650245bb1a11e67be61df875c6992d592c9cb17675d914997bd72c9fe7eb5b65c32
    HEAD_REF master
    PATCHES
        build_fix.patch
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS -DBUILD_EXAMPLE=OFF
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libuvc)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
