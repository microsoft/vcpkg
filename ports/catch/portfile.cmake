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
    URLS "https://github.com/philsquared/Catch/releases/download/v1.9.1/catch.hpp"
    FILENAME "catch.hpp"
    SHA512 129f4ed4cf7c32ee8f6ead1d4d1e8d4243929a62a857e921637dd39043066350f1674af0502a4d27cc3b29d64951558fe73e18d48d96a34e7a4dff9506ba0b48
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/v1.9.1/LICENSE.txt"
    FILENAME "LICENSE.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include )
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/catch/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/catch/copyright)
