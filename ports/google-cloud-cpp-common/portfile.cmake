include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp-common
    REF v0.15.0
    SHA512 0a723f714f63fbaa1900e4725b051445de614ed8a4700a6ad27037f9b63e56a7e9c5b4490e42044f077496074a8e0c3e7971bbcd601527c9f9fa20f088a19fa3
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
