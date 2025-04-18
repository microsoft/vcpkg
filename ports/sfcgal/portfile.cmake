vcpkg_from_gitlab(
	GITLAB_URL https://gitlab.com
	OUT_SOURCE_PATH SOURCE_PATH
	REPO sfcgal/SFCGAL
	REF "v${VERSION}"
	SHA512 c22dcb67cd79e31361e02164f6054cdcf64b341fb95d63b5082bf71cf5fccb310304826c554c60a0c8f0bdf3369515de56d41309b835133076133a908e3cf768
	HEAD_REF master
	)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SFCGAL_USE_STATIC_LIBS)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
	-DSFCGAL_BUILD_TESTS=OFF
	"-DSFCGAL_USE_STATIC_LIBS=${SFCGAL_USE_STATIC_LIBS}"
	-DBUILD_TESTING=OFF
	)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH bin/sfcgal-config)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

