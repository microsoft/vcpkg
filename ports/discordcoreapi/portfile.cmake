vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 171f7cbd687ef00de2f3e1924b538b61c4f6a627
	SHA512 b1848120411faf21ae34261a8788dbd8cc7a7f5f1ccf8e8b9b70b9253a2b9de9703fd49298f2f0cdacc65959f6230d2478f29619ab874279d6295be1d5748ffd
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
