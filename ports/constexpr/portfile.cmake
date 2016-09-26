include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "https://github.com/elbeno/constexpr/archive/a98b1db39c909e0130d21d3910d4faf97035a625.zip"
    FILENAME "constexpr-a98b1db39c909e0130d21d3910d4faf97035a625.zip"
    SHA512 847E09F9DF30CB5FBD8AA280679FF359D73C9E9454FFE3090F66975A15665080629E9A664D057F039B17430D42B5E5F5F3F92831E73C15024060991090209C2E
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
set(SOURCE_DIR ${CURRENT_BUILDTREES_DIR}/src/constexpr-a98b1db39c909e0130d21d3910d4faf97035a625)
file(COPY ${SOURCE_DIR}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/constexpr/README.md)
file(COPY ${SOURCE_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/constexpr/copyright)

# Copy the constexpr header files
file(GLOB HEADER_FILES ${SOURCE_DIR}/src/include/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
