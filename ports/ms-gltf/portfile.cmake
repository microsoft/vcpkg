if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/glTF-SDK
    REF ac3e70392feb6aef18a07314669f6af2ebc72787 # r1.9.5.4
    SHA512 389b801ddc6f0b29269bcd1215fa9e63fe46a1f1a8778125c6439e34fe0925d5534b1cdbea30824a4a8aa008015124dc7cc4558daa9522fc6d85e00e8e41e4a9
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
set(WINDOWS_USE_MSBUILD)
if(VCPKG_TARGET_IS_WINDOWS)
    set(WINDOWS_USE_MSBUILD "WINDOWS_USE_MSBUILD")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${WINDOWS_USE_MSBUILD}
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
