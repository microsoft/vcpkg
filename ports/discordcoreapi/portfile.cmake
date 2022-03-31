vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 11b3e059b2113ce866cb81a05881fe7a96fff63c
	SHA512 810c1f389fbbec6cd7a5e7ff66ce7beb7cc8a6ac092a600d9d9af0637a98b46e670c4308ece44b7b7c750345c257e28cdd6e436084fd70f2f674ba3708d84872
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
