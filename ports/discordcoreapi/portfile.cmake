if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 7ecf0bcdea655fc3b5058b901e0f6a7f00db604b
	SHA512 351ffb6b42bf8f694ddf6e8e391ed3b19b7422d4a4107ca579f69c1c45b9e67a1bf5e110173607dff9e8a62c5f5768d27aba0f7439546f24f5aa222810e7554a
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