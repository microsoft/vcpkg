vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/robin-hood-hashing
	REF 3.11.5
	SHA512 0
	HEAD_REF master
    PATCHES
        fix-missing-stdint.patch
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DRH_STANDALONE_PROJECT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
	PACKAGE_NAME robin_hood
	CONFIG_PATH lib/cmake/robin_hood
)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug"
	"${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
