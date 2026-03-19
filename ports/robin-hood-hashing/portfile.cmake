vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO martinus/robin-hood-hashing
	REF 3.11.5
	SHA512 5f73e089b1e8ec41a9bedded22bc64a789d3a3d04873a2ad9f8cc2970797a473b0f4d3436c2324b3ced85a0d983998a75b1dfaf2b7f3b77235b29806ff2fd489
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
