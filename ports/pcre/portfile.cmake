set(PCRE_VERSION 8.44)
set(EXPECTED_SHA adddec1236b25ff1c90e73835c2ba25d60a5839cbde2d6be7838a8ec099f7443dede931dc39002943243e21afea572eda71ee8739058e72235a192e4324398f0)
set(PATCHES
        # Fix CMake Deprecation Warning concerning OLD behavior for policy CMP0026
        # Suppress MSVC compiler warnings C4703, C4146, C4308, which fixes errors
        # under x64-uwp and arm-uwp
        pcre-8.44_suppress_cmake_and_compiler_warnings-errors.patch
        export-cmake-targets.patch)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.zip"
    FILENAME "pcre-${PCRE_VERSION}.zip"
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
        REPO pcre/pcre
        REF ${PCRE_VERSION}
        FILENAME "pcre-${PCRE_VERSION}.zip"
        SHA512 ${EXPECTED_SHA}
        PATCHES ${PATCHES}
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DPCRE_BUILD_TESTS=NO
            -DPCRE_BUILD_PCREGREP=NO
            -DPCRE_BUILD_PCRE32=YES
            -DPCRE_BUILD_PCRE16=YES
            -DPCRE_BUILD_PCRE8=YES
            -DPCRE_SUPPORT_JIT=YES
            -DPCRE_SUPPORT_UTF=YES
            -DPCRE_SUPPORT_UNICODE_PROPERTIES=YES
            # optional dependencies for PCREGREP
            -DPCRE_SUPPORT_LIBBZ2=OFF
            -DPCRE_SUPPORT_LIBZ=OFF
            -DPCRE_SUPPORT_LIBEDIT=OFF
            -DPCRE_SUPPORT_LIBREADLINE=OFF
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

foreach(FILE ${CURRENT_PACKAGES_DIR}/include/pcre.h ${CURRENT_PACKAGES_DIR}/include/pcreposix.h)
    file(READ ${FILE} PCRE_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(PCRE_STATIC)" "1" PCRE_H "${PCRE_H}")
    else()
        string(REPLACE "defined(PCRE_STATIC)" "0" PCRE_H "${PCRE_H}")
    endif()
    file(WRITE ${FILE} "${PCRE_H}")
endforeach()

# Create pkgconfig files
set(PACKAGE_VERSION ${PCRE_VERSION})
set(prefix "${CURRENT_INSTALLED_DIR}")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
if(VCPKG_TARGET_IS_LINUX)
    # Used here in .pc.in files: Libs.private: @PTHREAD_CFLAGS@
    set(PTHREAD_CFLAGS "-pthread")
endif()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    
    configure_file("${SOURCE_PATH}/libpcre.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpcre.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcre16.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpcre16.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcre32.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpcre32.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcrecpp.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpcrecpp.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcreposix.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libpcreposix.pc" @ONLY)
endif()
# debug
set(prefix "${CURRENT_INSTALLED_DIR}/debug")
set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/../include")
if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    configure_file("${SOURCE_PATH}/libpcre.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcre16.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre16.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcre32.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre32.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcrecpp.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcrecpp.pc" @ONLY)
    configure_file("${SOURCE_PATH}/libpcreposix.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcreposix.pc" @ONLY)

    if (VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre.pc
            "-lpcre" "-lpcred"
        )
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre16.pc
            "-lpcre16" "-lpcre16d"
        )
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcre32.pc
            "-lpcre32" "-lpcre32d"
        )
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcrecpp.pc
            "-lpcre -lpcrecpp" "-lpcred -lpcrecppd"
        )
        vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libpcreposix.pc
            "-lpcreposix" "-lpcreposixd"
        )
    endif()
endif()

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

vcpkg_copy_pdbs()
configure_file(${CMAKE_CURRENT_LIST_DIR}/unofficial-pcre-config.cmake ${CURRENT_PACKAGES_DIR}/share/unofficial-pcre/unofficial-pcre-config.cmake @ONLY)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

