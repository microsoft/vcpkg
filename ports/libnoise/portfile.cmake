include(vcpkg_common_functions)

set( LIBNOISE_VERSION "1.0.0" )
set( LIBNOISE_COMMIT "d7e68784a2b24c632868506780eba336ede74ecd" )

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RobertHue/libnoise
    REF ${LIBNOISE_COMMIT}
    SHA512 8c4d654acb4ae3d90ee62ebdf0447f876022dcb887ebfad88f39b09d29183a58e6fc1b1f1d03edff804975c8befcc6eda33c44797495285aae338c2e869a14d7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/libnoise)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libnoise/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/libnoise/copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME libnoise)