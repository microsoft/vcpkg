include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/crow-0.1)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/ipkn/crow/archive/v0.1.tar.gz"
    FILENAME "crow-v0.1.tar.gz"
    SHA512 5a97c5b8cda3ffe79001aa382d4391eddde30027401bbb1d9c85c70ea715f556d3659f5eac0b9d9192c19d13718f19ad6bdf49d67bef03b21e75300d60e7d02a
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/crow RENAME copyright)
