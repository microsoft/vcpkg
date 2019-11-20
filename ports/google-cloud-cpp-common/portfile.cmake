include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp-common
    REF v0.16.0
    SHA512 2325e4aa28cd883091a562f3de0390bb0139446920183487ed2fbc1e404c90ec6f5e42d5b6f59e1de65be66b61954bc4f66b3f441ad6ec89cd4591ce8ea3321d
    HEAD_REF master)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH} PREFER_NINJA DISABLE_PARALLEL_CONFIGURE OPTIONS
    -DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF
    -DBUILD_TESTING=OFF
    -DGOOGLE_CLOUD_CPP_TESTING_UTIL_ENABLE_INSTALL=OFF)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(
    INSTALL ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/google-cloud-cpp-common
    RENAME copyright)

vcpkg_copy_pdbs()
