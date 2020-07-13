set(PCRE2_VERSION 10.35)
set(EXPECTED_SHA bf1cb6ab8b1103f9503609783945b02cdc4294bb266643d0ba03656c941f07b6e183793f3bf513da950460e78cb9b429bff8ade27d8930339a63caed3a3236e3)
set(PATCHES
        pcre2-10.35_fix-space.patch # Upstream: https://bugs.exim.org/show_bug.cgi?id=2588
        pcre2-10.35_fix-uwp.patch
        pcre2-10.35_fix_postfix_for_debug_Windows_builds.patch # Upstream: https://bugs.exim.org/show_bug.cgi?id=2600
        pcre2-10.35_add_check_for_Intel_CET.patch # Upstream: https://bugs.exim.org/show_bug.cgi?id=2578
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

# don't install POSIX wrapper
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/pcre2posix.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/pcre2-posix.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pcre2-posixd.lib)
file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/pcre2-posix.dll ${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-posixd.dll)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpcre2-posix.pc ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre2-posix.pc)

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
