set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
set(VCPKG_BUILD_TYPE release) # tools only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skvadrik/re2c
    REF "${VERSION}"
    SHA512 7528d78e1354c774783e63e05553b7a772f8185b43b988cddf79a527ed63316f18e6f9fb3a63ae4d5c83c9f4de2b672b0e61898d96bdd6f15a1eaa7b4d47c757
    HEAD_REF master
    PATCHES
        re2c-3.1-optional-python.diff
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        go RE2C_BUILD_RE2GO
        rust RE2C_BUILD_RE2RUST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} "-DRE2C_BUILD_TESTS=OFF"
)

vcpkg_cmake_install()

vcpkg_copy_tools(
    TOOL_NAMES re2c
    AUTO_CLEAN
)
if(RE2C_BUILD_RE2GO)
    vcpkg_copy_tools(
        TOOL_NAMES re2go
        AUTO_CLEAN
    )
endif()
if(RE2C_BUILD_RE2RUST)
    vcpkg_copy_tools(
        TOOL_NAMES re2rust
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
