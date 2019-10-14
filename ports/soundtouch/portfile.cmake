include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "WindowsStore not supported")
endif()

set(VERSION 2.0.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.surina.net/soundtouch/soundtouch-${VERSION}.zip"
    FILENAME "soundtouch-${VERSION}.zip"
    SHA512 50ef36b6cd21c16e235b908c5518e29b159b11f658a014c47fe767d3d8acebaefefec0ce253b4ed322cbd26387c69c0ed464ddace0c098e61d56d55c198117a5
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/source/SoundTouchDLL/SoundTouchDLL.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/COPYING.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
