vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 0abce85daccb0c9ff221e972ff95e1965e9100e5
	SHA512 40f1267c621b18ae81fc70f7eb067aa002dbbdc5d1dfaddd316431599df1029ed508c70a8ee771c9d618790fd9eae376feabea72cd5094c31c8a9bb3e4211cc7
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
