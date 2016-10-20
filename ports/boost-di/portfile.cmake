include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/di-1.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/boost-experimental/di/archive/v1.0.1.tar.gz"
    FILENAME "di-1.0.1.tar.gz"
    SHA512 4e7270be51e7c8d0dcb6e0ba4bcf8e12904016086bdd59667954815f4acb03fc62447775885594a8403f5067a20b2520717fe979926d740dff0efa0c97ebf20c
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/include/boost
	DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# boost-di license does not exist in source folder.
# it shares the boost license.
file(DOWNLOAD http://www.boost.org/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/boost-di/copyright)