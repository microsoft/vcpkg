include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fruit-3.4.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/google/fruit/archive/v3.4.0.zip"
    FILENAME "fruit-3.4.0.zip"
    SHA512 29b85954f6157bd09e531a0a7283253682da547f1328f565844641a3b6e72c822bf4bd781807dc91d77ea86d137eb2a937f9a93783a8f30ff91e0ad3c4a4d5e2
)
vcpkg_extract_source_archive(${ARCHIVE})

# TODO: Make boost an optional dependency?
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    	-DFRUIT_USES_BOOST=False
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fruit RENAME copyright)
