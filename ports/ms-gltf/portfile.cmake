if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/glTF-SDK
    REF r1.9.6.0
    SHA512 c2d45f89a87b891580a747c82ca3c14d6946b5b266f248ebae5f748d1ec867a80ca49d1d33bd381ca3cd54666172079a727c0030ef83ae384bdc4dc9786520f1
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
