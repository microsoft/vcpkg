# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

set(PCRE_VERSION 8.41)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pcre-${PCRE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.zip" 
         "https://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.zip"
    FILENAME "pcre-${PCRE_VERSION}.zip"
    SHA512 a3fd57090a5d9ce9d608aeecd59f42f04deea5b86a5c5899bdb25b18d8ec3a89b2b52b62e325c6485a87411eb65f1421604f80c3eaa653bd7dbab05ad22795ea
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-option-2.patch
            ${CMAKE_CURRENT_LIST_DIR}/fix-arm-config-define.patch)

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

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcre)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcre/COPYING ${CURRENT_PACKAGES_DIR}/share/pcre/copyright)

vcpkg_copy_pdbs()