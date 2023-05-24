# TODO(coryan) - fix support for DLLs
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GoogleCloudPlatform/functions-framework-cpp
    REF v1.1.0
    SHA512 2dcedbded84fdd604724b4f2482ee531aaa640ebdbb69f77978e1af8943d9d7746152953953ebd89d8304ed3efbc334c620890142b0ba2e1239862e43a158364
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME functions_framework_cpp CONFIG_PATH lib/cmake/functions_framework_cpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(
    INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
