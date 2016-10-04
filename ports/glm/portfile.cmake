include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glm)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/g-truc/glm/releases/download/0.9.8.1/glm-0.9.8.1.zip"
    FILENAME "glm-0.9.8.1.zip"
    SHA512 93223ea7a08d969331a6b93d598c0b59dfc09e86770661c444f81939bd175053d3f6b1211a4aa4e59d732df39b97fe491eb35d4ac2efb286a1cf68ed29bfa80a
)
vcpkg_extract_source_archive(${ARCHIVE})

# Remove glm/CMakeLists.txt
file(REMOVE ${SOURCE_PATH}/glm/CMakeLists.txt)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/copying.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glm/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glm/copying.txt ${CURRENT_PACKAGES_DIR}/share/glm/copyright)

# Copy the glm header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/glm/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/glm)
