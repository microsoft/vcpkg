include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF f1b5105a8cd56d6ff46eee5eb26276e3fd92abbd
    SHA512 ea5f32433e2545ddab7ce5caf254fc05ef577fb076ca090ac225f15b88ec1b0a661490b4741aa8d4f579f910067736b8c28ecb320dc5cee62e5ab2735f05e38d
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-c-common/cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/cmake)

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