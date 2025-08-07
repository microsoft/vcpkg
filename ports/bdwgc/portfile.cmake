vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF "v${VERSION}"
    SHA512 da03597f7c947dd54adc3a489b781540d905b92ffb5fb6487d0c8b5121b301522ab07bdbda0a8930c7ac7655c7048d1dd0853786a56a7ff248e96745f0e36f43
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Denable_cplusplus=ON
        -Denable_docs=OFF
        -DCFLAGS_EXTRA=-I${CURRENT_INSTALLED_DIR}/include # for libatomic_ops
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bdwgc)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/README.QUICK" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
