set(PCRE2_VERSION 10.37)
set(EXPECTED_SHA f91760a8e0747f52211612fb0e134d685e224d16bd884eb574718d077a586b1fd7b6435d4e3b75c879b12e02b252467ecc28cdc4bc2903c783dacab089f99c99)
set(PATCHES
        pcre2-10.35_fix-uwp.patch
)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.pcre.org/pub/pcre/pcre2-${PCRE2_VERSION}.zip"
    FILENAME "pcre2-${PCRE2_VERSION}.zip"
    SHA512 ${EXPECTED_SHA}
    SILENT_EXIT
)

if (EXISTS "${ARCHIVE}")
    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        PATCHES ${PATCHES}
    )
else()
    vcpkg_from_sourceforge(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO pcre/pcre2
        REF ${PCRE2_VERSION}
        FILENAME "pcre2-${PCRE2_VERSION}.zip"
        SHA512 ${EXPECTED_SHA}
        PATCHES ${PATCHES}
    )
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Emscripten" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(JIT OFF)
else()
    set(JIT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPCRE2_BUILD_PCRE2_8=ON
        -DPCRE2_BUILD_PCRE2_16=ON
        -DPCRE2_BUILD_PCRE2_32=ON
        -DPCRE2_SUPPORT_JIT=${JIT}
        -DPCRE2_SUPPORT_UNICODE=ON
        -DPCRE2_BUILD_TESTS=OFF
        -DPCRE2_BUILD_PCRE2GREP=OFF)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/pcre2.h PCRE2_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(PCRE2_STATIC)" "1" PCRE2_H "${PCRE2_H}")
else()
    string(REPLACE "defined(PCRE2_STATIC)" "0" PCRE2_H "${PCRE2_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/pcre2.h "${PCRE2_H}")

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
