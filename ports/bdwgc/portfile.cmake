vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bdwgc/bdwgc
    REF "v${VERSION}"
    SHA512 af8dddd97390e2c44ef5d5bb47f5e4dac43b1932927fbe2154525f88cae40424af26f20c0cf282960383454d7af1a4139fad85bfc208f10191ef5828786fbae3
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
