vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googlecartographer/cartographer
    REF ${VERSION}
    SHA512 4e3b38ee40d9758cbd51f087578b82efb7d1199b4b7696d31f45938ac06250caaea2b4d85ccb0a848c958ba187a0101ee95c87323ca236c613995b23b215041c
    HEAD_REF master
	PATCHES
        fix-find-packages.patch
        fix-build-error.patch
        fix-cmake-location.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DFORCE_DEBUG_BUILD=True
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/cartographer/CartographerTargets.cmake" "${SOURCE_PATH}/;" "")
vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
