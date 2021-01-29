vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO jbcoe/polymorphic_value
	REF 1.3.0
	SHA512 67d49933c46d2a2bccb68c65c6f28b92603e193c68ff434b2c6b1602a573855a176fc98227d85cd24a64ae9299461adb42e792b4f165482bb250488620161742
	HEAD_REF master
	PATCHES 001_no_catch_submodule.patch
		002_fixed_config.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DBUILD_TESTING=OFF
)

vcpkg_install_cmake()
if(VCPKG_HEAD_VERSION)
	vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/polymorphic_value TARGET_PATH share/polymorphic_value)
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
else()
	vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/polymorphic_value)
	file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.txt")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(
	INSTALL ${SOURCE_PATH}/LICENSE.txt 
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
	RENAME copyright
)

