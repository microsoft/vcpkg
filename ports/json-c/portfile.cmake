vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF d28ac67dde77566f53a97f22b4ea7cb36afe6582
    SHA512 30063c8e32eb82e170647363055119f2f7eab19e1c3152673b966f41ed07e0349c3d6141b215b9912f9e84c2e06677b3d7ac949f720c7ebc2c95d692dc3881fe
    HEAD_REF master
    PATCHES pkgconfig.patch
            fix-clang-cl.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
