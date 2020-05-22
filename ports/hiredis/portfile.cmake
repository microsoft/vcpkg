if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF e777b0295eeeda89ee2ecef6ec5cb54889033d94
    SHA512 9486ce3e40580ca6a1da8a31c3e139eb8b5e17ac1b94bd0987f2435aeb2465ad271784d5e8e83dc6cbaf362f95c9e175efa5fbe80a63c56070ceb212d3d68470
    HEAD_REF master
    PATCHES
        fix-feature-example.patch
        support-static-in-win.patch
        fix-timeval.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ssl     ENABLE_SSL 
    example ENABLE_EXAMPLES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
