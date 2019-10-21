include(vcpkg_common_functions)

set(PCRE_VERSION 8.41)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.zip"
         "https://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.zip"
    FILENAME "pcre-${PCRE_VERSION}.zip"
    SHA512 a3fd57090a5d9ce9d608aeecd59f42f04deea5b86a5c5899bdb25b18d8ec3a89b2b52b62e325c6485a87411eb65f1421604f80c3eaa653bd7dbab05ad22795ea
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-option-2.patch
        fix-arm-config-define.patch
        fix-arm64-config-define.patch
)

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

foreach(FILE ${CURRENT_PACKAGES_DIR}/include/pcre.h ${CURRENT_PACKAGES_DIR}/include/pcreposix.h)
    file(READ ${FILE} PCRE_H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        string(REPLACE "defined(PCRE_STATIC)" "1" PCRE_H "${PCRE_H}")
    else()
        string(REPLACE "defined(PCRE_STATIC)" "0" PCRE_H "${PCRE_H}")
    endif()
    file(WRITE ${FILE} "${PCRE_H}")
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
