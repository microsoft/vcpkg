#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/stb-e713a69f1ea6ee1e0d55725ed0731520045a5993)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nothings/stb/archive/e713a69f1ea6ee1e0d55725ed0731520045a5993.zip"
    FILENAME "stb-e713a69f1ea6ee1e0d55725ed0731520045a5993.zip"
    SHA512 28d73905e626bf286bc42e30bc50e8449912a9db5e421e09bfbd17790de1909fe9df19c96d6ad3125a6ae0947d45b11b83ee5965dab68d1eadd0c332e391400e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/stb/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/stb/README.md ${CURRENT_PACKAGES_DIR}/share/stb/copyright)

# Copy the stb header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
