include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/g-truc/glm/releases/download/0.9.8.0/glm-0.9.8.0.zip"
    FILENAME "glm-0.9.8.0.zip"
    SHA512 5fe9d1f582e7bbef37fd23c9d10fd9cf7696bb7c6f8086a250248e97f84b0205a89a195c8838a1ddc4c0a4cb4c69d1764f90db6513a9691a94877b7ec6b2befb
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
