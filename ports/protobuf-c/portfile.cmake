vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protobuf-c/protobuf-c
    REF v${VERSION}
    SHA512 57f858118a89befc80e111ad9a57eadbcf2317d60e085b6d99e10f6604ee8c08473fe6ab1fdfb0a3196821a6e68e743943338321d23d15a1229987f140341181
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
        TOOL_NAMES protoc-gen-c
        AUTO_CLEAN
    )
endif()

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
