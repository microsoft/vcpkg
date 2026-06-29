vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrtulka23/scinumtools3
    REF v0.5.5
    SHA512 563d87eb9ef89222c21e63e7fd2e08c8f0e9a72375d5f1939e07243aac3e6142270e4e80f28933519226c4f14d090bc5e443bb756e363b3b45df3b58fc2c5444
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