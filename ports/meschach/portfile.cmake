vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://homepage.math.uiowa.edu/~dstewart/meschach/mesch12b.tar.gz"
    FILENAME "mesch12b.tar.gz"
    SHA512 9051e1502b8c9741400c61fd6038e514887f305f267ba4e97d747423de3da1270f835f65b2d1f538f8938677060bc0fcfd7a94022d74fbfd31a0450116e9d79e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/meschach)
