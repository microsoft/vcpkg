vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dropbox/json11
    REF ec4e45219af1d7cde3d58b49ed762376fccf1ace
    SHA512 2129e048d8dee027dc1ba789d9901e017b7d698465e15236802ef68639161e1cc7c8665d5f50079333801717fd41ffbe2cb90fa2165b9a85629e8ced8f2b3cd8
    HEAD_REF master
    PATCHES destination.patch
            fix-gcc15-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJSON11_BUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${CURRENT_PORT_DIR}/json11-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
