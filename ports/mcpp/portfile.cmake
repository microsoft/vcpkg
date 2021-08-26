vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO zeroc-ice/mcpp
	REF e6abf9a561294b667bb931b80cf749c9be2d1a2f
	SHA512 131b68401683bcfb947ac4969a59aa4c1683412c30f76c50e9e9c5c952a881b9950127db2ef22c96968d8c90d26bcdb5a90fb1b77d4dda7dee67bfe4a2676b35
	HEAD_REF master
	PATCHES
		0001-fix-_POSIX_C_SOURCE.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
)

vcpkg_install_cmake()

file(
	INSTALL 
		${SOURCE_PATH}/mcpp_lib.h
		${SOURCE_PATH}/mcpp_out.h
	DESTINATION 
		${CURRENT_PACKAGES_DIR}/include
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
