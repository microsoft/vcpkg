set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steven-varga/h5cpp
    REF 096842706ca65479a99e390f5ad289aff6051f18
    SHA512 0127ee6b029ba248b72e48624cee4c91089f6d65f0ac66b891dcbc14cef8b39878b87c2cd0d85b801c391331852513b2e039a1b78b890fbb74d34c3f889c45f9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DH5CPP_BUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/${PORT}/cmake)
file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug
	${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
