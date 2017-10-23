include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "libexif currently only supports being built for desktop")
endif()

set(LIBEXIF_VERSION 0.6.21)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libexif-${LIBEXIF_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://freefr.dl.sourceforge.net/project/libexif/libexif/${LIBEXIF_VERSION}/libexif-${LIBEXIF_VERSION}.tar.bz2"
    FILENAME "libexif-${LIBEXIF_VERSION}.tar.bz2"
    SHA512 4e0fe2abe85d1c95b41cb3abe1f6333dc3a9eb69dba106a674a78d74a4d5b9c5a19647118fa1cc2d72b98a29853394f1519eda9e2889eb28d3be26b21c7cfc35
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libexif.def    DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libexif RENAME copyright)
