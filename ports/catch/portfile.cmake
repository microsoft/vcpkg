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
    URLS "https://raw.githubusercontent.com/philsquared/Catch/master/single_include/catch.hpp"
    #https://raw.githubusercontent.com/philsquared/Catch/master/LICENSE_1_0.txt
    FILENAME "catch.hpp"
    SHA512 64eec1c291826ef235433729dc18f150e47d2a761f80ec47264be08b3f756b310c6e3aa2c6c3c7b5e2f345f86489d561d9a694506654823077d0f6c7c22df7cd
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/master/LICENSE_1_0.txt"
    FILENAME "License_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include ) 
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/catch/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/catch/copyright) 


