vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-event-stream
    REF 873f1c035a5b6b4698280ee3798d1db5cc9ce86c # v0.1.6
    SHA512 1d043b6915046498f5b94f9c23e0256ab780b11a75ad9ba3c608e26129567482a58787f4e69c4df3c21a29a6d13ed7dddc46869f695bb268e6867298b73edf30
    HEAD_REF master
    PATCHES fix-cmake-target-path.patch
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

file(REMOVE_RECURSE	${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
