if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF e2363dc93064001a9dbf95675a6e1b4d4ad07d99
	SHA512 923281289d730018d53d737e8527cdb3c446ce90f3388f89a6e785300a5b321bc9a4ea9dbd1b34f96ac473ac11f2cc995e5b6358e966c396dda092c459c7d3ea
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