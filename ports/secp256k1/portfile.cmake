vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitcoin-core/secp256k1
    REF 3efeb9da21368c02cad58435b2ccdf6eb4b359c3
    SHA512 6d792943f9277a1b4c36dad62389cb38e0b93efb570b6af6c41afdb936d10ca30d4c2e4e743fc0f113d1f9785891d1e9d1fe224d7b8abd4197a9f5febf0febd6
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools       BUILD_TOOLS
        examples    BUILD_EXAMPLES
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
	OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/unofficial-${PORT}" PACKAGE_NAME unofficial-${PORT})

if (BUILD_TOOLS OR BUILD_EXAMPLES)
    set(SECP256K1_TOOLS "")
    if (BUILD_TOOLS)
        list(APPEND SECP256K1_TOOLS bench bench_internal bench_ecmult)
    endif()
    
    if (BUILD_EXAMPLES)
        list(APPEND SECP256K1_TOOLS ecdsa_example ecdh_example schnorr_example)
    endif()
    
    vcpkg_copy_tools(TOOL_NAMES ${SECP256K1_TOOLS} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
