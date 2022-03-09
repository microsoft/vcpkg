vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO injae/serdepp
    REF v0.1.4
    SHA512 da84ad82e882c0cada5c9dd3c77afd45aaf7b3b4eb150257b09b9b4854b349fdb2c39be2f6ba40bb39b34262e44609a02afba1ec860625f25a2313f7ac34a055
    HEAD_REF main
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSERDEPP_BUILD_TESTING=OFF
        -DENABLE_INLINE_CPPM_TOOLS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/serdepp)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/cmake"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/lib/cmake"
)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
