#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dx-1.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/sdcb/dx/archive/1.0.0.tar.gz"
    FILENAME "dx-1.0.0.tar.gz"
    SHA512 7d0e0550eb27c3a7d3a9c4b78f29290aaf60c02a7c2fabb6e4769673592bc031f8ed430cd777e02096b9b9a8981c7e05b45448bf5c182704e080e61eaeab62f8
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL
	${SOURCE_PATH}/dx.h
	${SOURCE_PATH}/debug.h
	${SOURCE_PATH}/handle.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/dx
)

file(INSTALL
	${SOURCE_PATH}/LICENSE
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/dx RENAME copyright)