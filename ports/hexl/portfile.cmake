vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hexl
    REF b4589b6149a46dd287bcc0c81c746f72bcf6b37d # 1.2.4
    SHA512 79eaec45cf5b83459e41cd26c58118a1d0fa4bc1f07ebb00ebd646c90effb0d1dc26f3c33d28f3f1d3cd1cdff8fd23053790156b1c1a736525681bb6fa1fe027
    HEAD_REF development
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" HEXL_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DHEXL_BENCHMARK=OFF
        -DHEXL_COVERAGE=OFF
        -DHEXL_TESTING=OFF
        -DHEXL_SHARED_LIB=${HEXL_SHARED}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "HEXL" CONFIG_PATH "lib/cmake/hexl-1.2.4")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
