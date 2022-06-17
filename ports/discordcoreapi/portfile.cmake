if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 6473bee7e190a07d9159be3116773eaab9e70fe2
	SHA512 fbc9be6855c86c5e28950c31ee085a1a96f69d471496884acd1d65c0ee1ed4dd25ae3d7a638ca93b12ea65bc49a53d253e7ffd3847b2d0a4ad820ce6439d77cd
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