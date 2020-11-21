vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF 3eea4353d4768c79899a67ca4d36bfc3005d5412
    SHA512 ee3d8926f4a26c8f67a9e79fe5da9883195d2e9f9fffa47bb9c3526150d1e0c179968af7222ca280574921feb3c45200da1ca4dc0b012b82aa57dbdef26dcc0a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ms-gsl SEAL_USE_MSGSL
    zlib SEAL_USE_ZLIB
    zstd SEAL_USE_ZSTD
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DSEAL_BUILD_DEPS=OFF
        -DSEAL_BUILD_EXAMPLES=OFF
        -DSEAL_BUILD_TESTS=OFF
        -DSEAL_BUILD_SEAL_C=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_build_cmake(TARGET seal LOGFILE_ROOT build)

vcpkg_install_cmake()

file(GLOB CONFIG_PATH RELATIVE "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/lib/cmake/SEAL-*")
if(NOT CONFIG_PATH)
    message(FATAL_ERROR "Could not find installed cmake config files.")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH "${CONFIG_PATH}")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
