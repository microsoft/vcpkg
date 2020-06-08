
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/tlk00/BitMagic/archive/v6.4.0.zip"
    FILENAME "bitmagic2.zip"
    SHA512 b179d71c3600d39bbd795bfd790bbd10124d713b8ca050e6a021b510e1a01715ead1eb2c42601c5bbfd9b6b02cbe1778ef6c3952ac4a4e6c3fd0c6edc990c3f3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}

)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DPSNIP_INSTALL_HEADERS=OFF
    OPTIONS_RELEASE
        -DPSNIP_INSTALL_HEADERS=ON
)

file(GLOB HEADER_LIST "${PROJECT_SOURCE_DIR}/src/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/license ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

