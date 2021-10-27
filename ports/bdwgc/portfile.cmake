vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF 59f15da55961928b05972d386054fb980bdc8cf0 # v8.2.0-20211013
    SHA512 f6b91f0ad9691d02b04d609d06b9d9aaf30a6e0bb93a5985f9e178128bc3a0b180a3366ecddafab43697fb28c6d0d5e814f99a7bbacad8da4550d3b6ea92bef6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -Dbuild_cord=OFF
        -Denable_threads=OFF # TODO: add libatomic_ops package and turn on threads
    OPTIONS_DEBUG
        -Dinstall_headers=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/bdwgc)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/README.QUICK" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
