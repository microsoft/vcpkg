vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF abbb921e0af973809f45b2f78f9f0d843bdabb8d # v8.3.0-20211130
    SHA512 f529cc0153379819710f4d84ee25d4d666a1d9c531fc01b2d9ce8091eca13a6f2fa8a06866cccfeec00b43e8c318036d5162a1bf79e1f22155dce1aab30ae70a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -Denable_cplusplus=ON
        -Dwith_libatomic_ops=ON
    OPTIONS_DEBUG
        -Denable_gc_assertions=ON
        -Dinstall_headers=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/bdwgc)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
