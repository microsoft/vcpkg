vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF f6c80b54daab495f60f907e6c3b943f4c9775694
	SHA512 c5e1727ff5381b97912b7f1c91d711fb8f350c7783d5dc3ef2e1b16f784ef0ff6f92ed9cce694cf33223109f7eabcd84ab1ab7da833f0a142cdd896134f6cdbc
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
