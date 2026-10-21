vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ddtdanilo/LMDB-wrapper-MISRA-C
    REF "v${VERSION}"
    SHA512 97ef5907023623b4342cdd48dfc931d964bb04a23991ad1ef9689c2f16f1e3a84a0b0316da0911a128bf16fd9ac34d8cab02b487f19fea34e53125464cfba189
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLMDB_WRAPPER_BUILD_TESTS=OFF
        -DLMDB_WRAPPER_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_build()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME lmdb_wrapper CONFIG_PATH lib/cmake/lmdb_wrapper)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
