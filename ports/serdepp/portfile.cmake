vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO injae/serdepp
    REF v0.1.4.1
    SHA512 623414807e43d03f1ef1f9b7f02f10148b2745f5487047df3a678f92ccbe0a0f5f7d76cc6e2e88097e2c0e2cf2dde60b4f33dc9c6aaeafc7cd2dc3adfd88959f
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
