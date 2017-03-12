#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/dx-1.0.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/sdcb/dx/archive/v1.0.1.tar.gz"
    FILENAME "dx-1.0.1.tar.gz"
    SHA512 b40eb4daf774bfdb394b207bb29652fbf44361f5d8f9b60509c7a3215cd403dbf0c10454979c0c2e97d839496ef20940070a42837375993cd67d58afacc990e0
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