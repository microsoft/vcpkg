set(LIBDATRIE_VERSION 0.2.10)

vcpkg_download_distfile(ARCHIVE
    URLS "https://linux.thai.net/pub/ThaiLinux/software/libthai/libdatrie-${LIBDATRIE_VERSION}.tar.xz"
    FILENAME "libdatrie-${LIBDATRIE_VERSION}.tar.xz"
    SHA512 ee68ded9d6e06c562da462d42e7e56098a82478d7b8547506200c3018b72536c4037a4e518924f779dc77d3ab139d93216bdb29ab4116b9dc9efd1a5d1eb9e31
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-exports.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-trietool.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.cmake DESTINATION ${SOURCE_PATH})

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(SKIP_TOOL ON)
else()
    set(SKIP_TOOL OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVERSION=${LIBDATRIE_VERSION}
    OPTIONS_RELEASE
        -DSKIP_TOOL=${SKIP_TOOL}
        -DSKIP_HEADERS=OFF
    OPTIONS_DEBUG
        -DSKIP_TOOL=ON
        -DSKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/trietool.exe ${CURRENT_PACKAGES_DIR}/tools/${PORT}/trietool.exe)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libdatrie RENAME copyright)
