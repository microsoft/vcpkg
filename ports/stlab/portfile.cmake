include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF v1.4.1
    SHA512 e9da6f2c570397842f5e73a681f49c5a77977fda430ec730eed6f19d04161172829b7f1adcafd416f0a3f35ea8717ca14e9b935b5ec8fa423e4951c3ba961c7a
    HEAD_REF develop    
    PATCHES dont-require-testing.patch
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