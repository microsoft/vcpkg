vcpkg_download_distfile(ARCHIVE_FILE
	URLS "https://gitlab.com/inivation/dv/dv-processing/-/package_files/39407206/download"
	FILENAME "dv-processing-1.4.0.tar.gz"
	SHA512 c734ebeeb322939eb882cdfbfdddea38abcfdbb6d47237a4891d77952c75294080f27c9cb70e0a29ec6ffe5263259d2e1020d13b0114700f768d18da48642d7d
)

vcpkg_extract_source_archive_ex(
	OUT_SOURCE_PATH SOURCE_PATH
	ARCHIVE ${ARCHIVE_FILE}
	REF 1.4.0
	PATCHES
		vcpkg-build.patch
)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
	        -DENABLE_TESTS=OFF
		-DENABLE_SAMPLES=OFF
		-DBUILD_CONFIG_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "dv-processing" CONFIG_PATH "share/dv-processing")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
