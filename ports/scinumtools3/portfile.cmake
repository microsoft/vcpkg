set(VCPKG_POLICY_ALLOW_EXES_IN_BIN enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrtulka23/scinumtools3
    REF v0.5.6
    SHA512 4a66a8ca16e9a38f63be0377df4ebeaf2b6d4172870799b8b983ccc94c14c5fe9ca6833292d5fe6d5361a813470a022041b19859d6dd871e4f965ea7adb27f51
)
message(STATUS "vcpkg github: ${SOURCE_PATH}")

#set(SOURCE_PATH "/path/to/scinumtools3")
#message(STATUS "vcpkg source path: ${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_UNIT_TESTS=OFF
        -DENABLE_BINDING_PYTHON=OFF

        -DENABLE_SNT=ON
        -DENABLE_EXS=ON
        -DENABLE_VAL=ON
        -DENABLE_PUQ=ON
        -DENABLE_DIP=ON
        -DENABLE_MAT=OFF
        -DENABLE_API=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME snt
    CONFIG_PATH lib/cmake/snt
)

# Headers should only be installed once.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)