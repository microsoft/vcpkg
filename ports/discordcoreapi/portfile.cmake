if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 6132b830dde03fde6699e4ae6087070f88544b26
	SHA512 494aaf228ee7219f1b31fb07a556585718c703de5d830074a82c3b5463064ddf21337a255fa030279bc0abca66d5c25fad1ce1d34b55f483b5bfaf4e9ae21f42
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