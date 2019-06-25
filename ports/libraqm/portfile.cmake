include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO HOST-Oman/libraqm
    REF v0.6.0
    SHA512 cd223d97b80e9d2cf26a5b68fbb84a87e53df819f12ffd06f84f1786a2207b34828d0888058a40c1d89a1466bb68b75dd326e25415afab029d51e1ed98f6a924
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/FindFribidi.cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCURRENT_PACKAGES_DIR=${CURRENT_PACKAGES_DIR}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libraqm RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME raqm)
