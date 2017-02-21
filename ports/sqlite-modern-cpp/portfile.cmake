# header only
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite_modern_cpp-2.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aminroosta/sqlite_modern_cpp/archive/v2.4.tar.gz"
    FILENAME "sqlite_modern_cpp-2.4.tar.gz"
    SHA512 99d8220c9dcbf7383c75ef8061bc792a4ea0b7e6e1290992f1604f66e77fcb5055af8c54c2d82b6a8d331359e2829d987b7528208f032f32699e1349296792db
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
vcpkg_download_distfile(LICENSE
	URLS https://raw.githubusercontent.com/aminroosta/sqlite_modern_cpp/1d7747fcbb16325ec6673477b06f0c780de24a27/License.txt
	FILENAME "sqlite_modern_cpp-2.4-license-mit.txt"
	SHA512 4ffc41d14902b37841463b9e9274537cb48523a7ab7e5fbbbd14a01820d141e367851b0496aa18546ddab96100e7381db7fc35621c795a97c3290b618e18a8bd
)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
