vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp-common
    REF v0.21.0
    SHA512 a339c6f57ac539f1c45f2fb92311e5d48e29a4406a1e0cfda2f1dc18e8c6db345588ad0bebd2c23531e572982d4429ee73b4f0c3df1ba8028d4100d9b12ecaa1
    HEAD_REF master)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTING
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
    ${FEATURE_OPTIONS}
    -DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
