vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 0f6c07eae69151e606acb3d9232750c3442dff23
    SHA512 fbe315ae6b30f9fa834ab6bfb15a6fa555b8f79b774a1677830d51939a6dba5266ab5051e823d129a0a83deb979713699aa937b6f9229500d42c6b1495bbb0be
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRE2_TEST=OFF
        -DRE2_BENCHMARK=OFF
        -DRE2_BUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
