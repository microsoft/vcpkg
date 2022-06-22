if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 8fa614bb3a55e0516e8a17c86a0cd9045e872ddd
	SHA512 40f4d9df30156276056cce275731e0bb6ccfd9ecbc105677531cf82e21bf7103ab5402c4ef7fe8d0dbdff6e6156cef272a830bf9d739866605ef6b71d6e2dcec
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(
	INSTALL "${SOURCE_PATH}/License.md"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
