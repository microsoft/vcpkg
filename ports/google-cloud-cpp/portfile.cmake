include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO googleapis/google-cloud-cpp
    REF v0.13.0
    SHA512 68e8ccf5308208e59f644f52d7433baacc1e1253c444a4f90886aab73d4dbe72bfd4b3f7ac667f1df708b0c9f3546cef0421d6ffdae9fc4c1979608c3cfce648
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DGOOGLE_CLOUD_CPP_DEPENDENCY_PROVIDER=package
        -DGOOGLE_CLOUD_CPP_ENABLE_MACOS_OPENSSL_CHECK=OFF
	    -DBUILD_TESTING=OFF
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/google-cloud-cpp RENAME copyright)

vcpkg_copy_pdbs()
