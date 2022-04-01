vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 29fa8031982bfa79d25bf9173e430b56914f6192
	SHA512 6c788313c2fb7ed59e6f1a84755d193501ad0bf7973ca9dc1bd71de34258616700610f1e872e6c843371c163b12529bd2213cc021e061b7aab2e7bfdce4ba1be
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
