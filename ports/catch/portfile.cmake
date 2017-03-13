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
    URLS "https://github.com/philsquared/Catch/releases/download/v1.8.1/catch.hpp"
    FILENAME "catch.hpp"
    SHA512 942acee9ac54d170a79f4624ce62bc5d9327a863f5565352eb71f2c028d35c2042bf0416530cb8288b27ed78a46d0d02dfaba47e1d79ae9b394943771543ea3f
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/e27c4ee04282f60aefcc9b1062a74f92cf6c1a2b/LICENSE_1_0.txt"
    FILENAME "License_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include ) 
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/catch/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/catch/copyright) 


