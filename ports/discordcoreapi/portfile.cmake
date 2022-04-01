vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 34466089001341b6ed19cee2be45f1c8a020a2ec
	SHA512 31d3b756f0c9152546fe1cba12f7499cc46241f99f3a5a2db3d3769cbfb7a7f735b7363e0eff98e343625e1b6778e422f841aef9970d868f2e7085a13184bdc8
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
