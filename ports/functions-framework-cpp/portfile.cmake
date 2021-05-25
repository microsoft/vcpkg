# TODO(coryan) - fix support for DLLs
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GoogleCloudPlatform/functions-framework-cpp
    REF v0.5.0
    SHA512 cc7ba39a86a035625e09e653f1c60ee5125a449a2822c26b3e30d6ed3d84bfce93a8e627069b1c50e0dddcaf0277d82681627d653d42a3e967d191b2d979e2e8
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)

vcpkg_copy_pdbs()
