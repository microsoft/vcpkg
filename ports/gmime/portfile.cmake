include(vcpkg_common_functions)

set(LIB_NAME gmime)
set(LIB_VERSION 3.2.3)

set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.xz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gmime/3.2/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 abaf9059baf0c045d5b62757953ee2fa0779462eb32142bb41be40c376fc7ac2b3e4a56fd66177fbbe1dca35c6168a251542b14a844125c2cfcc9a99888179b4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIB_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# We can use file supplied with original sources
configure_file(${SOURCE_PATH}/build/vs2010/unistd.h ${SOURCE_PATH} COPYONLY)

configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h ${SOURCE_PATH})
configure_file(${CMAKE_CURRENT_LIST_DIR}/gmime.def ${SOURCE_PATH} COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${LIB_NAME} RENAME copyright)

vcpkg_copy_pdbs()
