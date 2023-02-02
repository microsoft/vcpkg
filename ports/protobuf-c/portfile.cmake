vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protobuf-c/protobuf-c
    REF v1.4.0
    SHA512 cba4c6116c0f2ebb034236e8455d493bfaa2517733befcd87b6f8d6d3df0c0149b17fcbf59cd1763fa2318119c664d0dae3d2d3a46ebfe2a0fec3ef4719b033b
    HEAD_REF master
    PATCHES
        fix-crt-linkage.patch
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
        TOOL_NAMES protoc-gen-c protoc-c
        AUTO_CLEAN
    )
endif()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove duplicate PDB files (vcpkg_copy_pdbs already copied them to "bin")
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/protobuf-c.pdb")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/lib/protobuf-c.pdb")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)