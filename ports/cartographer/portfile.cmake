vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googlecartographer/cartographer
    REF ${VERSION}
    SHA512 78b9950c8336776e945219c12a15272c439683144d7c97356f1cda569d02fba551735572c5ac103e9472c7ef6375908c9381205d93286c8ba3593324268d7099
    HEAD_REF master
	PATCHES
        fix-errors.patch
        update-cartographer-to-deal-with-newer-ceres-24.patch
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
