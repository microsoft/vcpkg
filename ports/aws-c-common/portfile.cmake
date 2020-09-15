vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF e3e7ccd35a85f9cd38c67cb1988251f1543b6632 # v0.4.15
    SHA512 f8be12628bb7503921bf64956697ad60ba1dc10099482515be7157a1f75b14fad716eadcf69af1d77a5f1bbdaf298a7913e678dd143c5b409dd37ce3bf57f023
    HEAD_REF master
    PATCHES
        disable-error-4068.patch # This patch fixes dependency port compilation failure
        disable-internal-crt-option.patch # Disable internal crt option because vcpkg contains crt processing flow
        fix-cmake-target-path.patch # Shared libraries and static libraries are not built at the same time
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

file(REMOVE_RECURSE	${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
