vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/libvpl
    REF "v${VERSION}"
    SHA512 bda6e8387f1e86eee86357a967ae58d9e87e2cada50317913ee8452e116220c5837643ea62c0b04baf9783daeca76d12ca63a34ce6acd6fb3ea2511bb47696bc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DINSTALL_EXAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DINSTALL_DEV=ON
        -DINSTALL_LIB=ON
        -DVPL_INSTALL_LICENSEDIR=${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright_tmp
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vpl" PACKAGE_NAME VPL)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright_tmp")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
