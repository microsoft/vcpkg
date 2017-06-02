# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "https://dedi4.nedprod.com/static/files/boost.outcome-v1.0-source-latest.tar.xz"
    FILENAME "boost.outcome-v1.0-source-latest.tar.xz"
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/include/boost DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# boost license does not exist in source folder.
vcpkg_download_distfile(LICENSE
	URLS http://www.boost.org/LICENSE_1_0.txt
	FILENAME "boost-outcome-copyright"
	SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-outcome/copyright)