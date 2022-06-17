if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF bca14515d938c0684b0b3a0e4a72e5c73e410096
	SHA512 7b1c2319904414eec3b3ddc9f8fb3de99e9dd85ee7cef435d8cbdcb480187c62571cb3f811d7ae2a36e3a77ad67907f76a5f5c442bcb71c54bb43e37f1b30b37
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(
	INSTALL "${SOURCE_PATH}/License.md"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)