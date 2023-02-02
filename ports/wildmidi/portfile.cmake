vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mindwerks/wildmidi
    REF wildmidi-0.4.5
    SHA512 0229914ecc60091b649b790a82ad5e755a2b9dfab7443fb3e3c19f4ae64b82817cafe74d78c27f05c68c3c8fb30092c96da732d27ff82fbd7dd7d577facc23d6
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
