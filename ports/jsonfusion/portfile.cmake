vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tucher/JsonFusion
    REF "v${VERSION}"
    SHA512 57312afa55a6ac3f91fa298eb4108114dd74c294418d139c22fc619fa2c7893db224a3e670571c5bde074f91cccba531d1d3e868ec1453158aa7c09c31b36321
    HEAD_REF master
)

# Install JsonFusion headers, excluding experimental 3party directory
# (3party is only used with JSONFUSION_FP_BACKEND=1, default is 0 with in-house implementation)
file(INSTALL "${SOURCE_PATH}/include/JsonFusion" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     PATTERN "3party" EXCLUDE)

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
