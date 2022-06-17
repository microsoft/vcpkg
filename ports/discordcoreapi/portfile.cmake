if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF b116f89d176ceb7277a30467dd2ea3777fcd0727
	SHA512 389f026ad4ffac6783171a7b2f5427f1cd2b09413561e59704a6a63589220ed18e174bba99407a3eba8a11728b0d570da2b8b046ae8d8443528c7e4ae32abdc8
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