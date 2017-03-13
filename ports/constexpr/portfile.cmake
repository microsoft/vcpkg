#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/constexpr-a98b1db39c909e0130d21d3910d4faf97035a625)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/elbeno/constexpr/archive/a98b1db39c909e0130d21d3910d4faf97035a625.zip"
    FILENAME "constexpr-a98b1db39c909e0130d21d3910d4faf97035a625.zip"
    SHA512 847e09f9df30cb5fbd8aa280679ff359d73c9e9454ffe3090f66975a15665080629e9a664d057f039b17430d42b5e5f5f3f92831e73c15024060991090209c2e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/constexpr/LICENSE)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/constexpr/LICENSE ${CURRENT_PACKAGES_DIR}/share/constexpr/copyright)

# Copy the constexpr header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
