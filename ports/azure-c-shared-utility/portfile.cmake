vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-c-shared-utility
    REF aed4fb49f2e70be535a2f8fef8c51844387f37e2
    SHA512 59e33bfa82edec4d474b09c397a769159cf8fa2adbcb5561793c975bee83440613b2ef6a7d8f2ccf6ca227caf4c99e003a48fdc40dcae3b18b7e9439adbc4ca5
    HEAD_REF master
    PATCHES
        fix-utilityFunctions-conditions.patch
        disable-error.patch
        modify-POSIX-c-version.patch
        fix-install-location.patch
        improve-dependencies.patch
        fix-curl-long-arg.patch
        fix-log-macro-compat.patch
        use-installed-c-logging.patch
)

# Build helpers c-utility uses from its deps/c-build-tools submodule (vcpkg sources have none).
vcpkg_from_github(
    OUT_SOURCE_PATH C_BUILD_TOOLS_PATH
    REPO Azure/c-build-tools
    REF b26bcf4a6a8eda025b1dce0a6bbfe02e2f7bb4e5
    SHA512 e3ab0bfe0d3a4ab818380111b211985f9c20ccbe012032e4638fc093ab8f19f585b679279c0ef78c81e6bca8fe0ffd821dd602ee72a6096a47e0fc9f814eb17d
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/deps/c-build-tools")
file(COPY "${C_BUILD_TOOLS_PATH}/" DESTINATION "${SOURCE_PATH}/deps/c-build-tools")
# Ports must not build with warnings as errors.
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " -Werror -Wall" " -Wall")
vcpkg_replace_string("${SOURCE_PATH}/deps/c-build-tools/build_functions/CMakeLists.txt" " /W4 /WX " " /W4 ")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
        -Drun_traceability=OFF
        -Dbuild_traceability_tool=OFF
        -Dbuild_csharp_projects=OFF
        -Dbuild_sarif_results_checker=OFF
        -Duse_ltcg=OFF
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME azure_c_shared_utility CONFIG_PATH lib/cmake/azure_c_shared_utility)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Included by the public headers but not installed by the build.
file(INSTALL "${SOURCE_PATH}/inc/azure_c_shared_utility/umock_c_prod_compat.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/azureiot/azure_c_shared_utility")

file(COPY "${SOURCE_PATH}/configs/azure_iot_build_rules.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_pdbs()
