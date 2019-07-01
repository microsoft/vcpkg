include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-checksums
    REF v0.1.2
    SHA512 d924918fce5179e2f42c0aeb86cb3bfda22f92bf3950e179f248a8d3e72c05a4f1015982970fd4075bb687a0a6e03120eee2134c0f017ec8ef69ae066881aa0d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-checksums/cmake)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-checksums
	${CURRENT_PACKAGES_DIR}/lib/aws-checksums
)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-checksums RENAME copyright)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/share
)