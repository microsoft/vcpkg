include(vcpkg_common_functions)

set(LIB_NAME gmime)
set(LIB_VERSION 3.0.5)

set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.xz)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIB_NAME}-${LIB_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gmime/3.0/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 658b9008ffdf8055ffa9dfe8a5a6036a487309b0419572a9376397f68a8fc17d36ba6a05d2dfcb2ad23e634dc9e2aedd2479df1bfa0b7f8944d4c294650cb6c8
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

# We can use file supplied with original sources
configure_file(${SOURCE_PATH}/build/vs2010/unistd.h ${SOURCE_PATH} COPYONLY)

configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h ${SOURCE_PATH})

configure_file(${CMAKE_CURRENT_LIST_DIR}/idna.h ${SOURCE_PATH} COPYONLY)
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
