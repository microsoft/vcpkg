if(VCPKG_TARGET_IS_WINDOWS) # Win32 and dynamic
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF e517482a6e51d7b2745479d2565d85b3e6f61391
    SHA512 245fdd90d3aa5b578cffabf00ad2b81456555f812c8b442b532c911492840f8f3b2855529ec972f9c45f13142393313f4c8b93b6fc2b2ce4118bcc06b861e061
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
