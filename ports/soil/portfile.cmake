include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.lonesock.net/files/soil.zip"
    FILENAME "soil-2008.07.07.zip"
    SHA512 a575a84aa65b7556320779d635561341f5cf156418d0462473e5d1eb082829be3bcb30600b4887af75aeddd3715de16bdb3ca1668ebaa93eea62bacf22b79548
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/SOILConfig.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/SOILConfigVersion.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/LICENSE
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
