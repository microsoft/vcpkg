vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 206605b89b6b8fd10612eb37ba7dadfa8ec1ded8
	SHA512 4ebd78f9b44a2efdc152cf9ea0601ae9c27082d7b6a0ec549cd1543ce5a3157a80acb0a6d30b61e2bdc60302cf623d099616d3bc7869f73d1df0ef5224170cc4
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

if (UNIX)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
