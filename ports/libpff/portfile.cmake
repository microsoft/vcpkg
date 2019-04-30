include(vcpkg_common_functions)

set(LIB_NAME libpff)
set(LIB_VERSION 20180714)

set(LIB_FILENAME libpff-experimental-${LIB_VERSION}.tar.gz)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message("Current version of libpff is not intended to be used as a static library")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libpff/releases/download/${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 7207ba87607ea2fd4609a081c2f4b061344a783e188605e88df99fd473f2a8da1269b065e57b054f4622888d40aa8f2b8272dc4748334ddfe358b28d443d6ad1
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIB_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${LIB_NAME} RENAME copyright)

vcpkg_copy_pdbs()
