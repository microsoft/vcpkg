vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO cpp-netlib/url
        REF v1.13.0
        SHA512 187898f5c0d2919095b293c7fbb6757d7b1391c9c79ccc3467ffc8b76a10685fd91faf9e9b8b0c0c21d0a9aecb3a50d52f2eab52823e770fc10ecd6ed874a748
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -Dskyr_BUILD_TESTS=OFF
            -Dskyr_BUILD_DOCS=OFF
            -Dskyr_BUILD_EXAMPLES=OFF
            -Dskyr_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/skyr-url)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE_1_0.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
