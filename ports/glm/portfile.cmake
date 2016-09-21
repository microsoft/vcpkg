include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/g-truc/glm/releases/download/0.9.8.0/glm-0.9.8.0.zip"
    FILENAME "glm-0.9.8.0.zip"
    MD5 b24613c1f7e16f504d936ae3ac1f4917
)
vcpkg_extract_source_archive(${ARCHIVE})

# Remove glm/CMakeLists.txt
file(REMOVE ${CURRENT_BUILDTREES_DIR}/src/glm/glm/CMakeLists.txt)

# Put the license file where vcpkg expects it
file(COPY ${CURRENT_BUILDTREES_DIR}/src/glm/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glm/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glm/copying.txt ${CURRENT_PACKAGES_DIR}/share/glm/copyright)

# Copy the glm header files
file(GLOB HEADER_FILES ${CURRENT_BUILDTREES_DIR}/src/glm/glm/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/glm)
