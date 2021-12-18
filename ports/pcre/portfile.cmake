set(PCRE_VERSION 8.45)
set(EXPECTED_SHA 71f246c0abbf356222933ad1604cab87a1a2a3cd8054a0b9d6deb25e0735ce9f40f923d14cbd21f32fdac7283794270afcb0f221ad24662ac35934fcb73675cd)
set(PATCHES
        # Fix CMake Deprecation Warning concerning OLD behavior for policy CMP0026
        # Suppress MSVC compiler warnings C4703, C4146, C4308, which fixes errors
        # under x64-uwp and arm-uwp
        pcre-8.45_suppress_cmake_and_compiler_warnings-errors.patch
        # Modified for 8.45 from https://bugs.exim.org/show_bug.cgi?id=2600
        pcre-8.45_fix_postfix_for_debug_Windows_builds.patch
        export-cmake-targets.patch)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pcre/pcre
    REF ${PCRE_VERSION}
    FILENAME "pcre-${PCRE_VERSION}.zip"
    SHA512 ${EXPECTED_SHA}
    PATCHES ${PATCHES}
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPCRE_BUILD_TESTS=NO
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

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-${PORT}" CONFIG_PATH "share/unofficial-${PORT}")

foreach(FILE "${CURRENT_PACKAGES_DIR}/include/pcre.h" "${CURRENT_PACKAGES_DIR}/include/pcreposix.h")
    file(READ ${FILE} PCRE_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(PCRE_STATIC)" "1" PCRE_H "${PCRE_H}")
    else()
        string(REPLACE "defined(PCRE_STATIC)" "0" PCRE_H "${PCRE_H}")
    endif()
    file(WRITE ${FILE} "${PCRE_H}")
endforeach()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pcre-config" "${CURRENT_PACKAGES_DIR}/debug/bin/pcre-config")
endif()

vcpkg_copy_pdbs()
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-pcre-config.cmake" "${CURRENT_PACKAGES_DIR}/share/unofficial-pcre/unofficial-pcre-config.cmake" @ONLY)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
