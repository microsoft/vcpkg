vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ftylitak/qzxing
    REF "v${VERSION}"
    SHA512 21ab9960fafc5eb5e2907e22e31d29d9b4db66480e65ba26d86bededa708d51abc2fd1a9e959357402104e993653dc4aa9a6e6fcf9de362a74030c8bddad8411
    HEAD_REF master
    PATCHES
        use-qt6.patch
        allow-shared-build.patch
        add-cmake-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src"
    OPTIONS
        -DQZXING_MULTIMEDIA=OFF
        -DQZXING_USE_QML=OFF
        -DVERSION=${VERSION}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-qzxing)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
