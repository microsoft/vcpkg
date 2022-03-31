vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF bf09652ddeeaa07df1d5cfa38b09ded8331c0a1e
	SHA512 dcadf19e874b470492f0ca8397a80196d54ad4e530b6d56cc556cfc7177e40ed0b830e09a4ba0a4752c741bc3859653eb2b069dc68bb3461a0935e7ffd3cb550
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
