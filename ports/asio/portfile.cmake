#header-only library
include(vcpkg_common_functions)

vcpkg_download_distfile(
	ARCHIVE_FILE
	URLS "https://sourceforge.net/projects/asio/files/asio/1.12.1%20%28Stable%29/asio-1.12.1.zip/download"
	FILENAME "asio-1.12.1.zip"
	SHA512 f35a519cde88824f65bde095c19d69449d0779e75da9e9ebb6a04f4847802213e8730715756a21632c4d27722cd5568ff7878d656ac79165a8bdf8652fbc1bd8
)

vcpkg_extract_source_archive(
	${ARCHIVE_FILE}
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/asio-1.12.1)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")

# Always use "ASIO_STANDALONE" to avoid boost dependency
file(READ "${CURRENT_PACKAGES_DIR}/include/asio/detail/config.hpp" _contents)
string(REPLACE "defined(ASIO_STANDALONE)" "!defined(VCPKG_DISABLE_ASIO_STANDALONE)" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/asio/detail/config.hpp" "${_contents}")
