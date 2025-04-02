vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/di
    REF "v${VERSION}"
    SHA512 e18303b99579b7158dea83c710888e50f518eb8c3f873742613a99b56eaf77fc6b132ee13ca88eb5d434e54580745fa6c395b1f6324fbd94d58706536a95ffee
    HEAD_REF cpp14
)

file(INSTALL ${SOURCE_PATH}/include/boost
    DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if ("extensions" IN_LIST FEATURES)
	file(INSTALL ${SOURCE_PATH}/extension/include/boost
		DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

vcpkg_download_distfile(LICENSE
    URLS https://www.boost.org/LICENSE_1_0.txt
    FILENAME "di-copyright"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
vcpkg_install_copyright(FILE_LIST "${LICENSE}")
