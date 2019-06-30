include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/libpmemobj-cpp
    REF 1.7
    SHA512 1caea1227baa0f36190a108cbf7150fd7022175a138d81167bb25d4b1c5dba14a5c16c37477f8895b5c4f9fd460c7c43560ceeccc4ad088f94b50de18637173b
    HEAD_REF master
    PATCHES disable-perl.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_DOC=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/libpmemobj++/cmake TARGET_PATH share/libpmemobj++)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/doc ${CURRENT_PACKAGES_DIR}/lib/libpmemobj++)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
