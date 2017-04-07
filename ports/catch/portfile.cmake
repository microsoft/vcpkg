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
    URLS "https://github.com/philsquared/Catch/releases/download/v1.9.0/catch.hpp"
    FILENAME "catch.hpp"
    SHA512 2f5a4a4b84bda0ba26c2d4523db1f880d957f312c6dc8772621a3f69c7a9cdf495990b25f07523a403e01b37105313f9541a60b729bd6f47756573077028e816
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/v1.9.0/LICENSE.txt"
    FILENAME "LICENSE.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include ) 
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/catch/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/catch/copyright) 


