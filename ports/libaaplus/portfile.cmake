include(vcpkg_common_functions)

set(VERSION 2.10.0)

vcpkg_download_distfile(
    ARCHIVE_FILE
    URLS "http://www.naughter.com/download/aaplus.zip"
    FILENAME "aaplus.zip"
    SHA512 ef814a36fa567e806be5e5345abd89e1a8d32da1c392c251e5b74aea86b866ebc74bc17885a0eff303b170cfe226670cd6f69095702396cc9d6fcbc1a769de4f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE_FILE}
	REF ${VERSION}
	NO_REMOVE_ONE_LEVEL
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(
    INSTALL ${SOURCE_PATH}/AA+.htm
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libaaplus
    RENAME copyright
)

vcpkg_test_cmake(PACKAGE_NAME LIBAAPLUS MODULE)
