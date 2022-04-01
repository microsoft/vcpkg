vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF a7ead38372540c146dd83c60c06d11e4a59a206a
	SHA512 78a4f2e091f2c71ea4e20f2524ae12314c4ffb7dc4b9aa2e8429dfb23271db30f9900e34d98d8cd28efbb81205f94622d8695cf9e8f96a2758275f182ad42ba4
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
