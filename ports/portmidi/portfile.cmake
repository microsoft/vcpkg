vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PortMidi/portmidi
    REF v2.0.4
    SHA512 d9f22d161e1dd9a4bde1971bb2b6e5352da51545f4fe5ecad11c55e7a535f0d88efce18d1c8fd91e93b70a7926150f86a0f53972ad92370e86556a8dd72dc194
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    SET(PM_USE_STATIC_RUNTIME ON)
else()
    SET(PM_USE_STATIC_RUNTIME OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DPM_USE_STATIC_RUNTIME="${PM_USE_STATIC_RUNTIME}"
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PortMidi)

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
