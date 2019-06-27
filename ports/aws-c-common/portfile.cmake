include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF v0.3.11
    SHA512 da845f748aecfff61209f542f4eac8d46738af52ce980d5c8315397f859429dfd9e4bf989ddf2fbe938d1efb33dce9c531c92cbe53388b1d1082d5caa97e8750
    HEAD_REF master
    PATCHES
        fix-dependencey-build-error.patch # This patch fixes dependency port compilation failure
        disable-internal-crt-option.patch # Disable internal crt option because vcpkg contains crt processing flow
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-c-common/cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-common
	${CURRENT_PACKAGES_DIR}/lib/aws-c-common
	)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-c-common RENAME copyright)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/share
)
