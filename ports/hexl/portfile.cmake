vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hexl
    REF "v${VERSION}"
    SHA512 1a5e42fdeac877f3b4ef87ab75ffa8280697e941d7a8f0f6dc8c5066f2dd405470530dfabdf12d846362bd3e7e6cd30fd1f11d8dd99bee5086d09371ba1da196
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
vcpkg_cmake_config_fixup(PACKAGE_NAME "HEXL" CONFIG_PATH "lib/cmake/hexl-${VERSION}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
