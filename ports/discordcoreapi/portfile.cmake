if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF b882ab3e35ff91a7ac1d2e5ca043b263e0c556ea
	SHA512 77d665e761c1c7c4fe949bcaba06a9393b917c9968df86fd650bc399055ddcfa7ca2286076edc5e7a1c2abbad65de2f830673b18fd06fd9e02d4176aa8be0a73
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