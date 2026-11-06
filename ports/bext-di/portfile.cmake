vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/di
    REF "v${VERSION}"
    SHA512 354ca3db8b93e8077d77b35f849860583d621de60c931a0830517b4e918b2f88710e2894f7248098bf1ced328b6c31e88fec86762e148e26d62d5f2968e91f4d
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
