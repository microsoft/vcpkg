include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/utfcpp-2.3.4)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/nemtrif/utfcpp/archive/v2.3.4.tar.gz"
    FILENAME "utfcpp-2.3.4.tar.gz"
    SHA512 1baa67c4efb926bba97dfbc869ac057d5d6cf67e94879fc0854ec3d75a5bae7c47cb3e9fd9cbc7bed9ca5daf40f173c0349bce2f6aa34a400bdf77d01522ff2f
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/source/utf8.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/utfcpp RENAME copyright)

# Copy the utf8-cpp header files
file(COPY ${SOURCE_PATH}/source/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
