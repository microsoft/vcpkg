vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KaSSaaaa/gqlxy-server
    REF bc708bef99298e8a693ad3d248ec0a0025c9e322
    SHA512 eaa6d2490257d3985009061bb6b9dad922f96f748eb14ef5a3b953ab9bd311a2609b5ee71edb8849256f70935c47f49423d221aad5f01c8eb67b5cdfdef36209
    HEAD_REF main
    PATCHES
        disable-samples.patch
)

# No dllexport annotations; shared builds only work on non-Windows.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        standalone-server BUILD_STANDALONE_SERVER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_SAMPLES=OFF
        -DENABLE_VCPKG_BOOTSTRAP=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME gqlxy-server CONFIG_PATH lib/cmake/gqlxy-server)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
