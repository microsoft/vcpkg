vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF "${VERSION}"
    SHA512 5f553990632cb15d996ccfa92641167863807867baa9ff0b9a94ae0e40daf782df1746e75ea228a93892be1f574c9261838c9edb94e40bbf559ab22f21068c41
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_TESTS=OFF
        -DINSTALL_PROJECT=ON
        -DCMAKE_POLICY_DEFAULT_CMP0057=NEW
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/miniz)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
