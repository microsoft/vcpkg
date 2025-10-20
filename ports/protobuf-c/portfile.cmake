vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protobuf-c/protobuf-c
    REF v${VERSION}
    SHA512 c95ec5fa4d3531fb83c9db95968e62a60c5e16cb10fb390067eca35ccb9e0c65c1e667bbdc9b7aa3b8f6cf012b09a189d6833534d2a28e390f01ae0d12052a47
    HEAD_REF master
    PATCHES
        fix-crt-linkage.patch
        fix-dependency-protobuf.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_PROTOC
        test  BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/build-cmake"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES protoc-gen-c
        AUTO_CLEAN
    )
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/protobuf-c")

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove duplicate PDB files (vcpkg_copy_pdbs already copied them to "bin")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/protobuf-c.pdb")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/protobuf-c.pdb")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
