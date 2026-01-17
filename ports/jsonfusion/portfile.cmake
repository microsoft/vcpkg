vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tucher/JsonFusion
    REF "v${VERSION}"
    SHA512 4f9068ae571b140b67499a8bc5e10a0af5aed7cf8a1fc53b77c36f73e60f2546c3a6585ad903d0169e4e57ab8d2914905f62419f27218b94ebaf2235de02ce8f
    HEAD_REF master
)

# Install JsonFusion headers, excluding experimental 3party directory
# (3party is only used with JSONFUSION_FP_BACKEND=1, default is 0 with in-house implementation)
file(INSTALL "${SOURCE_PATH}/include/JsonFusion" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     PATTERN "3party" EXCLUDE)

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
