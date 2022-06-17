if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 22e973f4e7755f292b34cd1589e2d54fbb0e2865
	SHA512 91006e548a74e30079a40488d828557a00b4ab3c646a70c0027b3f49d5f4db5b0e2d4b67b8e1df43285eb28302856fecb043089d3d3e70324e511f1a2a802ee9
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(
	INSTALL "${SOURCE_PATH}/License.md"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)