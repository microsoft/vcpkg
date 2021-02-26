# TODO(coryan) - fix support for DLLs
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GoogleCloudPlatform/functions-framework-cpp
    REF v0.4.0
    SHA512 89f1322cdefcafcff84a3afa95529068481dfb4f3ae363cd81e8b5a54f1d9158c402e2fa3f441428e6ab41e6c91d1280ebff8c3b6e239e4c064cedad34a15d6d
    HEAD_REF main
    PATCHES
    	0001-fix-msvc-build.patch
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
