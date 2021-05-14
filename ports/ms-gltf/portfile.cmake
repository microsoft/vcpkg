vcpkg_fail_port_install(MESSAGE "ms-gltf currently only supports Windows and Mac platforms" ON_TARGET "linux" "ios")
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/glTF-SDK
    REF 9428f114b540fb93e6533d5ec460fc123efe0c86 # todo: r1.9.6.0
    SHA512 900caf6d72d360bae4c7af769a8879507f7f727b40f61723ffed679ad22877fb37daed2a0dfcbf27e15ab3adc8afe3249530b95691ce489b3446e5d9a35f205a
    HEAD_REF master
    PATCHES
        fix-install.patch
        fix-apple-filesystem.patch
)

# note: Test/Sample executables won't be installed
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        test    ENABLE_UNIT_TESTS
        samples ENABLE_SAMPLES
)

# note: Platform-native buildsystem will be more helpful to launch/debug the tests/samples.
# note: The PDB file path is making Ninja fails to install. 
#       For Windows, we rely on /MP. The other platforms should be able to build with PREFER_NINJA.
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
