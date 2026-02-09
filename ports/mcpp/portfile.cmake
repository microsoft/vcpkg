vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO zeroc-ice/mcpp
	REF "v${VERSION}"
	SHA512 06a2ccf461c09aec6916e623a1ae59da7db1509a0ba5ceedcfeec2d32a71986bd8ce249cbf99232eaa8f347ee035dd5da5868e7d96ab7ae6270ebdac1b06b498
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
