vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortMidi/portmidi
    REF "v${VERSION}"
    SHA512 d66e9587324da729f3f97037decc8dbd436f86aa346969e4f9189f74a8f60451a92db4c5a5f551064cf794e872c174ebe731bcb2aaf6554f00dacc5b3b8209be 
    HEAD_REF master
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
