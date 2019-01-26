include(vcpkg_common_functions)

set(_libxml2_version 2.9.9)

vcpkg_download_distfile(ARCHIVE
    URLS "ftp://xmlsoft.org/libxml2/libxml2-${_libxml2_version}.tar.gz" "http://xmlsoft.org/sources/libxml2-${_libxml2_version}.tar.gz"
    FILENAME "libxml2-${_libxml2_version}.tar.gz"
    SHA512 cb7784ba4e72e942614e12e4f83f4ceb275f3d738b30e3b5c1f25edf8e9fa6789e854685974eed95b362049dbf6c8e7357e0327d64c681ed390534ac154e6810
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${_libxml2_version}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DPORT_DIR=${CMAKE_CURRENT_LIST_DIR}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxml2)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libxml2/COPYING ${CURRENT_PACKAGES_DIR}/share/libxml2/copyright)

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxml2)
endif()
