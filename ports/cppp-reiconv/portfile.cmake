# We do not use vcpkg_from_github here, as build-aux and cppp-platform are not part of the repo.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cppp-project/cppp-reiconv/releases/download/v${VERSION}/cppp-reiconv-${VERSION}.zip"
    FILENAME "cppp-reiconv-v${VERSION}.zip"
    SHA512 08351752a3a8e6f816146c69e8e26dac450a1f2a8d5cdaf78328e1244bb03b4e9c092ac36928afffa24c7993573b4cd1e12866b43f8f33a764da46697285dfdf
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
