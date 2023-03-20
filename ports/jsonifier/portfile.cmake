vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF 8bceaa6
	SHA512 7190a0b1a11d22c9918eef95dd7d9a9ba5bcb6fd0e3ca953676bcbfa6be427a076930e0640597fed5f34c39c5106389de27272cf35c6d17e89336a24bd071ded
	HEAD_REF main
)
if ("${VCPKG_TARGET_TRIPLET}" == "x64_uwp")
else()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(
	INSTALL "${SOURCE_PATH}/License.md"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
endif()