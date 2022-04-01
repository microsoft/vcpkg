vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 47d1751fabf02a4c2c7e1c523e715892ba563a06
	SHA512 381e0596b5c1dc13649812ea18d773ba945820b41fec7e8e68268a4eacb07ce47ef0a50db9ddd7c973d2ecb1c8a54c67eb0a5df62678dbf172ed0b509454f30c
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
