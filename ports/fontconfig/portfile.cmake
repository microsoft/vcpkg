
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fontconfig-2.12.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.1.tar.gz"
    FILENAME "fontconfig-2.12.1.tar.gz"
    SHA512 0959a80522e09551e49ec7b2383b7dfb319d4e1c058ad0b55bb35d3f675acbb7ff08c9c30a8798b731070687f84dd3d2ff7e28aafac6ecfa9d3f85c5847c0955)

# Download single-header implementation of dirent API for Windows.
vcpkg_download_distfile(DIRENT_H
    URLS "https://raw.githubusercontent.com/tronkko/dirent/8b1db5092479a73d47eafd3de739b27e876e6bf3/include/dirent.h"
    FILENAME "fontconfig-dirent.h"
    SHA512 dc9e63fd9cf4ccffdc052f92933633ef9d09dfcfe3b1d15f1f32c99349babd36a62d02283e3d8ba7766d92817be015eb211f11efc4fa52cc90d532a34d1ae785)


vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${DIRENT_H} DESTINATION ${SOURCE_PATH})
file(RENAME ${SOURCE_PATH}/fontconfig-dirent.h ${SOURCE_PATH}/dirent.h)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
        -DFC_INCLUDE_DIR=${CMAKE_CURRENT_LIST_DIR}/include
    OPTIONS_DEBUG
        -DFC_SKIP_TOOLS=ON
        -DFC_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fontconfig)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fontconfig/COPYING ${CURRENT_PACKAGES_DIR}/share/fontconfig/copyright)
