vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortMidi/portmidi
    REF "v${VERSION}"
    SHA512 d9f22d161e1dd9a4bde1971bb2b6e5352da51545f4fe5ecad11c55e7a535f0d88efce18d1c8fd91e93b70a7926150f86a0f53972ad92370e86556a8dd72dc194
    HEAD_REF master
    PATCHES
        "search-for-threads-in-config.patch"
        "framework_link.patch"
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(PM_USE_STATIC_RUNTIME ON)
else()
    set(PM_USE_STATIC_RUNTIME OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPM_USE_STATIC_RUNTIME="${PM_USE_STATIC_RUNTIME}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortMidi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
