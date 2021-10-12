vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mindwerks/wildmidi
    REF wildmidi-0.4.4
    SHA512 5B74EE83F1D7CE3B45D2F996AAA30EC6E7D7808EAB294A3EAF6FCEF77443523DF1F54BB0FB1B3105EDD0D72D75885FDA1A2E97C68DEFB5BBD687BDA5077D3454
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set(WANT_STATIC "OFF")
else()
	set(WANT_STATIC "ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWANT_PLAYER=OFF
        -DWANT_STATIC=${WANT_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME WildMidi CONFIG_PATH lib/cmake/WildMidi)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

file(INSTALL "${SOURCE_PATH}/docs/license/LGPLv3.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
