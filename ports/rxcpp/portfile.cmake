#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/RxCpp-3.0.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/Reactive-Extensions/RxCpp/archive/v3.0.0.tar.gz"
    FILENAME "RxCpp-3.0.0.tar.gz"
    SHA512 f30f71cefee25f86297d66a49e752a44bdb8ad9a1a92249bf944101afd91b432564e9b8c9e8853f7042608030bffaa4d58d294f18a61f394701cee347f42bcbb
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

file(INSTALL
	${SOURCE_PATH}/Rx/v2/src
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
	${SOURCE_PATH}/license.md
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxcpp RENAME copyright)