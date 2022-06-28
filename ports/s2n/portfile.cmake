vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF 36c3dc72ab1359cf721294e1258dfdc2962f3ffc # v1.3.5
    SHA512 2c9eed12e90e5fc987758635fec4a7418c20d25c724cfa391090b06bfcc4eb5925b4011d51a99e7c7ab80f535684ee3934ba4734b7966edd323bf88bc5953d7c
    PATCHES
        fix-cmake-target-path.patch
        use-openssl-crypto.patch
        remove-trycompile.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tests   BUILD_TESTING
)

set(EXTRA_ARGS)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    set(EXTRA_ARGS "-DS2N_NO_PQ=TRUE")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${EXTRA_ARGS}
        ${FEATURE_OPTIONS}
        -DUNSAFE_TREAT_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/s2n/cmake)

if(BUILD_TESTING)
    message(STATUS Testing)
    vcpkg_cmake_build(TARGET test LOGFILE_BASE test)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/s2n"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/s2n"
    "${CURRENT_PACKAGES_DIR}/share/s2n/modules"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
