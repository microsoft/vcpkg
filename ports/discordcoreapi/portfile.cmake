if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 691d2eed0c0784d0151198c59c8349d054d82085
	SHA512 090c1d2416678d390a947be07b78703c1a8b71e040b1c4399bfc0b376e162354eb78f183f7ab2dbb8ecbcf64f6834392ef5f0873d4882f72b2485e0f67e42415
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