vcpkg_from_gitlab(
	GITLAB_URL https://gitlab.com/inivation/
	OUT_SOURCE_PATH SOURCE_PATH
	REPO dv/libcaer
	REF 3.3.14
	SHA512 6e91ebd20796b59c51ebb10be58d12577f3b6370425bbeffcf1a96ff91ad9f3ffaefb2741d0a932b241f2664c157d77158cf475b0f7e39ba208d5482f408fc8b
	HEAD_REF ab9470e8900364822fb74ad3c1e99fa4088914df
	PATCHES
		libcaer-static-build.patch
)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DENABLE_OPENCV=ON
		-DEXAMPLES_INSTALL=OFF
		-DENABLE_BINDIR_INSTALLATION=ON
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "libcaer" CONFIG_PATH "share/libcaer")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
