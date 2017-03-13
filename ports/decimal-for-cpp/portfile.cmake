# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

#header-only library

include(vcpkg_common_functions)

vcpkg_download_distfile(HEADER
    URLS "https://raw.githubusercontent.com/vpiotr/decimal_for_cpp/98287a0f0f48aaed2cc146d7682396ae08ed0aea/include/decimal.h"
    FILENAME "decimal.h"
    SHA512 9de1208760c74ff1e6b1a74957dabae33981d2f5d0ec402b48f27f4dc24c950ea69219a9ee9831959a8669a9c7908093d833a227924f1955cbe444a9f43c5f3a
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/vpiotr/decimal_for_cpp/98287a0f0f48aaed2cc146d7682396ae08ed0aea/doc/license.txt"
    FILENAME "decimal-for-cpp-License.txt"
    SHA512 0b2be46b07a0536404887fae9665d6532ffd4cbfefbec42926c14e055f538c1f3a73b6e61ab7fa1584e634ad99304133d18855197df0a914cbb835674cc67677
)


file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/decimal-for-cpp-License.txt ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/copyright)

