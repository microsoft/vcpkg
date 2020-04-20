vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/odygrd/quill/archive/v1.2.0.tar.gz"
    FILENAME "v1.2.0.tar.gz"
    SHA512 e86f2c986740fd814067caf9d50a26214ac0681d98cd1b48e84daff97a754fb733266a45cd22d530bb5ffa186b1e90af4f9771a35ad6fa76f267980b9fe91a74
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF 1.2.0
)

if("external_lib_fmt" IN_LIST FEATURES)
    # use vcpkg-provided fmt library (see also option QUILL_FMT_EXTERNAL)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/quill/quill/include/quill/bundled/fmt)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/quill/quill/src/bundled/fmt)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    external_lib_fmt QUILL_FMT_EXTERNAL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
	  ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quill)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
					
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
