# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pcre-8.38)
vcpkg_download_distfile(ARCHIVE
    URLS "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.zip"
    FILENAME "pcre-8.38.zip"
    SHA512 82f1c2bdd0a6cc086e3734621ac7a2773cb28f42cf5e400b9bbe8c16655465d9367bce82c6db69577c40ec137b30f1b2443a8d91998a514f81e1c2210828a113
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DPCRE_BUILD_TESTS=NO
            -DPCRE_BUILD_PCREGREP=NO
            -DPCRE_BUILD_PCRE32=YES
            -DPCRE_BUILD_PCRE16=YES
            -DPCRE_BUILD_PCRE8=YES
            -DPCRE_SUPPORT_JIT=YES
            -DPCRE_SUPPORT_UTF=YES
            -DPCRE_SUPPORT_UNICODE_PROPERTIES=YES
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcre)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcre/COPYING ${CURRENT_PACKAGES_DIR}/share/pcre/copyright)

vcpkg_copy_pdbs()