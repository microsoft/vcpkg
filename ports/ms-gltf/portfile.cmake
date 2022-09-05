if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/glTF-SDK
    REF eaccf166e2718c6133db426545b6d008cb7ad79f # 28-06-2022
    SHA512 112e31d2f42d2fb22060a687f7d33f22e677d8d7eca006eb8c1edef6a61b8bad637df15492665656ea88a5a0b980851eb978a180b4a01d307d1bbc92f63500f1
    HEAD_REF master
    PATCHES
        fix-install.patch
        fix-apple-filesystem.patch
)

# note: Test/Sample executables won't be installed
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test    ENABLE_UNIT_TESTS
        samples ENABLE_SAMPLES
)

# note: Platform-native buildsystem will be more helpful to launch/debug the tests/samples.
# note: The PDB file path is making Ninja fails to install.
#       For Windows, we rely on /MP. The other platforms should be able to build with PREFER_NINJA.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
