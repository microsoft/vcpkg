if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "DiscordCoreAPI only supports g++ 11 on linux.")
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF c39612005ddc0be74acc13902d12548ade12b1f4
	SHA512 0b0379240f4521ca3ae43be3d9fc7dac632e2c09afb15099bbf1209278698288799604e49cbbe6eb5bacacf2fa1dbed5a3497356819bbee418f1ad3bed837fe7
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