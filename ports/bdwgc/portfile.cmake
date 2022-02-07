vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    REF 5fab1a01931a1a6934ccf1d5eaa1e51f0a8dac4d # v8.2.0-20211115
    SHA512 b1a97aad10df33bb242985eb48f1bb2d3082d88f26c34014efce3d0f233bcd18a0f43f1bd960600ad9e22bcb19ebf04e573c74dfc1abfb771aa6b8525053c14b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -Denable_cplusplus=ON
        -DCFLAGS_EXTRA=-I${CURRENT_INSTALLED_DIR}/include # for libatomic_ops
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
