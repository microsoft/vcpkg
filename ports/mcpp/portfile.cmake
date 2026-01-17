vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO zeroc-ice/mcpp
	REF "v${VERSION}"
	SHA512 27f7be060e5c9ee4e87c44c99d2dd22c8b2454cb0776f7daef1b6eade2b016af1481d0b96a428ac4cce2152242b3c51bd2e144da0018989650a96e60c5d82a0f
	HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(
	INSTALL 
		"${SOURCE_PATH}/mcpp_lib.h"
		"${SOURCE_PATH}/mcpp_out.h"
	DESTINATION 
		"${CURRENT_PACKAGES_DIR}/include"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
