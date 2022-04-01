vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF de0cfa6402b6e22fd73cf5df0fa946f028455c90
	SHA512 2f7f8a00ca7334b59d18086d7d518e2e8337bfd0e974dc55885a31e2b7f26aece6f4c9f753153963c716f9cf318ed48c038dc36b65d0d6ee706f8b81becf22a9
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
