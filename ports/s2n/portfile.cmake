vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aws/s2n-tls
    REF ab9a3be5a8abcbc5bd7bdba662497a717737c838 # v1.3.0
    SHA512 0150cba56f7940253ffa5af0c27fdc8db08961d4c8a80377d25f588fa8a56249eb02723304969d0fdebe570388545527ee826a3070c21e50e63c4f021d425728
    PATCHES
        fix-cmake-target-path.patch
        use-openssl-crypto.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tests   BUILD_TESTING
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
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
