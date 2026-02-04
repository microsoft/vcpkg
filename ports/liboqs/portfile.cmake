vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-quantum-safe/liboqs
    REF ${VERSION}
    SHA512 d4a48335e2848c4ea4f5615af7846b21f83a9d8ff5256ebd0d27fa52e21bae3338de138770f07a4befea35b94f20ec8fd897594d45948c86d41c95cfe07be151
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOQS_BUILD_ONLY_LIB=ON
        -DOQS_PERMIT_UNSUPPORTED_ARCHITECTURE=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
