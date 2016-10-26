# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)

vcpkg_download_distfile(HEADER
    URLS "https://raw.githubusercontent.com/philsquared/Catch/e27c4ee04282f60aefcc9b1062a74f92cf6c1a2b/single_include/catch.hpp"
    FILENAME "catch.hpp"
    SHA512 c2fec38227bb1725c30f955583dbd012f86eef83512a0c154e91b77249df372db067710ae110463eb07adec722d214114fd6a2cebff7ee43c5fd567a6a1ba221
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/e27c4ee04282f60aefcc9b1062a74f92cf6c1a2b/LICENSE_1_0.txt"
    FILENAME "License_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include ) 
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/catch/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/catch/copyright) 


