include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF v1.3.3
    SHA512 2c0eec5638b40f8285cc3b0d756df619b53ba44421c47713aaf45196100765a31a6aea3c5bedba4fcc44494b74e3f0a919271601e717e7f274fe15beb93f8889
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

# cleanup
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cmake/stlab ${CURRENT_PACKAGES_DIR}/share/stlab)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/cmake)

# handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/stlab RENAME copyright)