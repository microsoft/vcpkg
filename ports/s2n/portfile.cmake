vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF "v${VERSION}"
    SHA512 1423308dc1e4907e6903831a62b2bade7de64ebbb8fd7e4eb655b544498488bb573413d2de65f4c085d535c5b76aa87d9dcf93d42c38fbafbbed0be5551ead8e
    PATCHES
        fix-cmake-target-path.patch
        openssl.patch
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
    message(STATUS "Testing")
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
