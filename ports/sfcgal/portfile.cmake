# Header only
vcpkg_buildpath_length_warning(37)

vcpkg_from_gitlab(
	GITLAB_URL https://gitlab.com
	OUT_SOURCE_PATH SOURCE_PATH
	REPO Oslandia/SFCGAL
	REF v1.5.1
	SHA512 8d33235512a14997b00b4419f42d1195fd40186b56af63cd4494555031799af2a2fc1d0b3c2cd706ce8f6fc6be844af60be3a57774515326a782494e1de44ec2 
	HEAD_REF master
	)


vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
	-DSFCGAL_BUILD_TESTS=OFF
	-DBUILD_TESTING=OFF
	)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH bin/sfcgal-config)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

