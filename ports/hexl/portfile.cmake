vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/hexl
    REF "v${VERSION}"
    SHA512 11cfbfbea70d8bb70bb1d5c5d741c18ce87adc9d1904ca30f603cd878eb6b29be0eaf78ca76a05ed2bdacab0370f89494851309cff1e847488d28ca79b891bce
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
