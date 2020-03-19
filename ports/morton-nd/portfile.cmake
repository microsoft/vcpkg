#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kevinhartman/morton-nd
    REF v3.0.0
    SHA512 659c903c0c4a4ee4179d01950a952fe0c40d2c426063c10515ae5d2ad13ec8ca6b83d8de50c9eb86dd3c2c3747e1594d832f0c28cd6d414703baf9a7ab2f1f36
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/morton-nd/cmake TARGET_PATH)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/share/doc
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
file(COPY ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
