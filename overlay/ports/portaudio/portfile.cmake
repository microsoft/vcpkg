vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Be-ing/portaudio
    REF e103b2c18cadd648bdc3aa057172537b72f56c64
    SHA512 952b791d135ead3529c65c0274599be4b9194e4615849144127f88f661cbb8323a821b20ba59eec92692d1fec7f43a432a7853ea335c0a785532f7ba73888a6b
    HEAD_REF cmake_rewrite
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DDEBUG_OUTPUT:BOOL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
