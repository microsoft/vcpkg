
include(vcpkg_common_functions)
set(FONTCONFIG_VERSION 2.12.3)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/fontconfig-${FONTCONFIG_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.gz"
    FILENAME "fontconfig-${FONTCONFIG_VERSION}.tar.gz"
    SHA512 b17725c028be1c5e6f76c136b0ed7db1be7694cbbf217310083512708e05cdc1a824427f89082e6ef259c10297900f26cbe899f7c5762e7662855739f3eff5ea)

# Download single-header implementation of dirent API for Windows and it's license
vcpkg_download_distfile(DIRENT_H
    URLS "https://raw.githubusercontent.com/tronkko/dirent/8b1db5092479a73d47eafd3de739b27e876e6bf3/include/dirent.h"
    FILENAME "fontconfig-dirent.h"
    SHA512 dc9e63fd9cf4ccffdc052f92933633ef9d09dfcfe3b1d15f1f32c99349babd36a62d02283e3d8ba7766d92817be015eb211f11efc4fa52cc90d532a34d1ae785)
vcpkg_download_distfile(DIRENT_LICENSE
    URLS "https://raw.githubusercontent.com/tronkko/dirent/8b1db5092479a73d47eafd3de739b27e876e6bf3/LICENSE"
    FILENAME "fontconfig-dirent-license"
    SHA512 58c294f80b679252dbee9687ff6bda660fe1ed6f94506e1b9edc19358de98b274b25b3697bdcd34becb28a4f186c6d321a16ab616164e2fb378b37357fc71e4f)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${DIRENT_H} DESTINATION ${SOURCE_PATH})
file(RENAME ${SOURCE_PATH}/fontconfig-dirent.h ${SOURCE_PATH}/dirent.h)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFC_INCLUDE_DIR=${CMAKE_CURRENT_LIST_DIR}/include
    OPTIONS_DEBUG
        -DFC_SKIP_TOOLS=ON
        -DFC_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER fcfreetype.h fontconfig.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER} FC_HEADER)
        string(REPLACE "#define FcPublic" "#define FcPublic __declspec(dllimport)" FC_HEADER "${FC_HEADER}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/fontconfig/${HEADER} "${FC_HEADER}")
    endforeach()
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fontconfig)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fontconfig/COPYING ${CURRENT_PACKAGES_DIR}/share/fontconfig/copyright)
file(COPY ${DIRENT_LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/fontconfig)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fontconfig/fontconfig-dirent-license ${CURRENT_PACKAGES_DIR}/share/fontconfig/dirent-for-vs-copyright)
