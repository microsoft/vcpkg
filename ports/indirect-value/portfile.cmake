vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbcoe/indirect_value
    REF 4152dcc5d2e35d03f3e71089508b47a8f630b8e7
    SHA512 fea37378041f9c770b76e6c68777d0fd5c27e28e7f83b0a7a021eb06aa279c959ab6d5f4d748e1f0fedd90c04965073850a855395b72574143fa1053704211ea
    HEAD_REF main
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DENABLE_CODE_COVERAGE=OFF
        -DENABLE_INCLUDE_NATVIS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME indirect_value CONFIG_PATH lib/cmake/indirect_value)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" )

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/indirect-value/")
