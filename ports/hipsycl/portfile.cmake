# NOTES:
#  - The following dependencies may be installed using vcpkg if not available on the computer
#     - llvm
#     - boost

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO illuhad/hipSYCL
    REF v0.9.2
    SHA512 0f315d051c7dd6e2ff217661ac85fca209ec6147c4e0898fdae8d3491cf160ea246694855d23883c4ca5c37196c65920fe0fc85ac08f6a44121f266f887795ad
    HEAD_REF master
    PATCHES
      config-file-path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda   WITH_CUDA_BACKEND
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_tools(
   TOOL_NAMES
      syclcc
      syclcc-clang 
      #      hipsycl-hcf-tool
   AUTO_CLEAN
)
vcpkg_cmake_config_fixup(PACKAGE_NAME "hipsycl" CONFIG_PATH "lib/cmake/hipSYCL")

# Remove include files from debug build
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install the etc/hipSYCL/syclcc.json config file into the share/hipsycl directory. Requires a patch in the syclcc python script.
file(INSTALL "${CURRENT_PACKAGES_DIR}/etc/hipSYCL/syclcc.json" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Copyright and license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

