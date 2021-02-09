vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Be-ing/portaudio
    REF 2d4d7d5f0fe29f34d30b5365411a2ff7587e94f5
    SHA512 5932b764bff2cc06fcff417c655d86d894541ced08afcd352cfc4c731d66052562d3987f1870b106d91e366b700e01fb01c58ec654566efce8b9d5247a1b87ee
    HEAD_REF cmake_rewrite
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    asio ASIO
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG -DDEBUG_OUTPUT:BOOL=ON
    PREFER_NINJA
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
