vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF v8.2.4
    SHA512 323d65a867f95cfbf5ecb0ff57e8dede0282cffd0d75153526e50282fe019b2e9b3a0cf16d551654832bd4f01ce8f8461590bfc5f4ea9b5eed80384321d369d7
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
