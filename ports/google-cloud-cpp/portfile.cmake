include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp
    REF v0.17.0
    SHA512 7bfa73db04fe8ff9344201eca8f56107fd895f18b3be44fca45a9f2d64224338980d04841de4418c5c1b7a8ac0768a60e93e5abbed9256567ca7b8bc2bf73cd9
    HEAD_REF master
    PATCHES
        0001-fix-x86-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DGOOGLE_CLOUD_CPP_DEPENDENCY_PROVIDER=package
        -DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/google-cloud-cpp RENAME copyright)

vcpkg_copy_pdbs()
