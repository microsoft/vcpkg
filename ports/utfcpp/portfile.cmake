#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/utfcpp-2.3.5)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/nemtrif/utfcpp/archive/v2.3.5.tar.gz"
    FILENAME "utfcpp-2.3.5.tar.gz"
    SHA512 d5e672de952b78a78a8af0c81664f15667b30558fd406a9abc72c14dc444e0869e7c02cb66fa017ec0e760c0fb23c3e923a4b171c2acb3ed7b71612783e789ee
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/source/utf8.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/utfcpp RENAME copyright)

# Copy the utf8-cpp header files
file(COPY ${SOURCE_PATH}/source/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
