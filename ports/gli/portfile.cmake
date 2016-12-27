#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gli-0.8.2.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/g-truc/gli/archive/0.8.2.0.tar.gz"
    FILENAME "0.8.2.0.tar.gz"
    SHA512 c254a4e1497d0add985e4a882c552db99c512cc0e9cc72145d51a6e7deada817d624d9818099a47136a8a3ef1223a26a34e355e3c713166f0bb062e506059834
)
vcpkg_extract_source_archive(${ARCHIVE})

# Remove glm/CMakeLists.txt
file(REMOVE ${SOURCE_PATH}/glm/CMakeLists.txt)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/external/glm/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gli/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gli/copying.txt ${CURRENT_PACKAGES_DIR}/share/gli/copyright)

# Copy the glm header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/gli/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/gli)
