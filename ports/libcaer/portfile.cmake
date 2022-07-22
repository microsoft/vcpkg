vcpkg_from_gitlab(
	GITLAB_URL https://gitlab.com/inivation/
	OUT_SOURCE_PATH SOURCE_PATH
	REPO dv/libcaer
	REF master
	SHA512 1d100f196ee0539b453323c31f8234a8de09aba22447c5eb5cf5249f0fc2a9712abc70da87a7acb3342dd5785f5fb12ba04e15b4b0a7e9c4dd4ba80773c9e36d
	HEAD_REF da6e7cc31a239cf6c071bb110a285f8ebd81c628
)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DENABLE_OPENCV=ON
		-DEXAMPLES_INSTALL=OFF
		-DBUILD_CONFIG_VCPKG=ON
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "libcaer" CONFIG_PATH "share/libcaer")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
