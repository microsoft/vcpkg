#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/di-1.0.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boost-experimental/di/archive/v1.0.2.tar.gz"
    FILENAME "di-1.0.2.tar.gz"
    SHA512 1a5fc3738db2c3c18c198ce58e82a60f4f3d39fb66c9dc2b465df89da66a19ffca79eca148e68cd70c76524185ba2145e2857504a25eda4fa70ffd2f05f3be40
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/include/boost
	DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# boost-di license does not exist in source folder.
# it shares the boost license.
vcpkg_download_distfile(LICENSE
	URLS http://www.boost.org/LICENSE_1_0.txt
	FILENAME "boost-di-copyright"
	SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-di/copyright)