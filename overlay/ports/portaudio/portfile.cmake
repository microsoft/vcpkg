vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Be-ing/portaudio
    REF 0f7ab8fe8b4ab73d9c301385d67eee367d4f3dcc
    SHA512 9f75f579349d776c93538f3aa8f4133d148da53029c73bc7635e2a2191709389e29d1f492ae6063b0ae768d4ae0b28738f6fddc65256d3eb1ac31fbba2f9eded
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
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
