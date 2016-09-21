include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/nothings/stb/archive/e713a69f1ea6ee1e0d55725ed0731520045a5993.zip"
    FILENAME "stb-e713a69f1ea6ee1e0d55725ed0731520045a5993.zip"
    MD5 5d81d3036610045d5a8076728c4e2f7e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
set(SOURCE_DIR ${CURRENT_BUILDTREES_DIR}/src/stb-e713a69f1ea6ee1e0d55725ed0731520045a5993)
file(COPY ${SOURCE_DIR}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/stb/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/stb/README.md ${CURRENT_PACKAGES_DIR}/share/stb/copyright)

# Copy the stb header files
file(GLOB HEADER_FILES ${SOURCE_DIR}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
