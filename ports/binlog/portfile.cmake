vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO morganstanley/binlog
    REF 3fef8846f5ef98e64211e7982c2ead67e0b185a6
    SHA512 106da76da3fc229211f8754306156bb7456d828678bfab18a0ad24f713ce1101debab4a75fe12bf7686bfab2f3f26eef66b57642447d7ddfb7de343f3ad8279d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBINLOG_BUILD_BREAD=OFF
        -DBINLOG_BUILD_BRECOVERY=OFF
        -DBINLOG_BUILD_EXAMPLES=OFF
        -DBINLOG_BUILD_UNIT_TESTS=OFF
        -DBINLOG_BUILD_INTEGRATION_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_benchmark=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/binlog")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_copy_pdbs()
