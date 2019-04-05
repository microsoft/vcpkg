include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GoogleCloudPlatform/google-cloud-cpp
    REF v0.8.0
    SHA512 cdb527169c7badab395eb38ba554022a364a99b9cb32705bf69a9613cee74acc1e2402e00ffdcb740467e85603e617f73b01e557afeb1f2786872f8d60f3a75a
    HEAD_REF master
	PATCHES
		cmake-libcurl-target.patch # Not needed _after_ v0.8.0
		cmake-libcurl-find-config.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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
