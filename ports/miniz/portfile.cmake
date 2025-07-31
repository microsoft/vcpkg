vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF c883286f1a6443720e7705450f59e579a4bbb8e2
    SHA512 56f8ad02ba695bcc469f0711423f7027faeb49515aac6ecd7bc4f86d6f40f6816f2c2fc893ec39379e39abfb7a2dbe2c53da38202f04a22e357eb0e5f6f375ff
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
vcpkg_copy_pdbs(BUILD_PATHS "${CURRENT_PACKAGES_DIR}/bin/*.dll")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/miniz)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
