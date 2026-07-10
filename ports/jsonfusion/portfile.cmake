vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tucher/JsonFusion
    REF "v${VERSION}"
    SHA512 fe8cb3068fc5ce7f5bacb708eb4c9947fa241b7cf29d50b1d285f5df243a164e063701de9bf1e486d6a38be0c9d0677d0ed0450b70e3878cdad1dbbae363bc36
    HEAD_REF master
)

# Install JsonFusion headers, excluding experimental 3party directory
# (3party is only used with JSONFUSION_FP_BACKEND=1, default is 0 with in-house implementation)
file(INSTALL "${SOURCE_PATH}/include/JsonFusion"
     DESTINATION "${CURRENT_PACKAGES_DIR}/include"
     PATTERN "3party" EXCLUDE)

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
