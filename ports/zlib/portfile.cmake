set(VERSION 1.2.11)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://www.zlib.net/zlib-${VERSION}.tar.gz" "https://downloads.sourceforge.net/project/libpng/zlib/${VERSION}/zlib-${VERSION}.tar.gz"
    FILENAME "zlib1211.tar.gz"
    SHA512 73fd3fff4adeccd4894084c15ddac89890cd10ef105dd5e1835e1e9bbb6a49ff229713bd197d203edfa17c2727700fce65a2a235f07568212d820dca88b528ae
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE_FILE}
    REF ${VERSION}
    PATCHES
        "cmake_dont_build_more_than_needed.patch"
        "0001-Prevent-invalid-inclusions-when-HAVE_-is-set-to-0.patch"
        "add_debug_postfix_on_mingw.patch"
        "0002-android-build-mingw.patch"
)

# This is generated during the cmake build
file(REMOVE ${SOURCE_PATH}/zconf.h)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSKIP_INSTALL_FILES=ON
        -DSKIP_BUILD_EXAMPLES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Install the pkgconfig file
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/zlib.pc "-lz" "-lzlib")
    endif()
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/zlib.pc DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string(${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zlib.pc "-lz" "-lzlibd")
    endif()
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zlib.pc DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
