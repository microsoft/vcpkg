include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-event-stream
    REF 0d1e206629e9b4cf7de1ccdb37b7996bb141d05b # v0.1.3
    SHA512 0bcbaee66a788ee246d5a5a6965d1bd52cf900d8151662b4449ca8a460227a7e6821a7725f6f490caa643df65379757529688cca62bdd42ed9d3d9abc37a614e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
		"-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common"
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/aws-c-event-stream/cmake)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-event-stream
	${CURRENT_PACKAGES_DIR}/lib/aws-c-event-stream
	)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-c-event-stream RENAME copyright)

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/share
)
