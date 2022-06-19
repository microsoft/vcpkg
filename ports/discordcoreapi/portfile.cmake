if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF d4e088ad23b8f88d77427e9668ef121a54889bc7
	SHA512 eeb60e6d9da5f9ae00e827a179f429fb5cf200a47c604409bacc76726ffe243d8925cbf12c988d40d5981e99488dd56cad6994d4403d0d8ebc45619c52179318
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