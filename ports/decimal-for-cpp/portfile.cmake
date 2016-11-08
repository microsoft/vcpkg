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
    URLS "https://github.com/vpiotr/decimal_for_cpp/blob/master/include/decimal.h"
    FILENAME "decimal.h"
    SHA512 46e29d76311df74422d240a4fd36e2689a9b58758da0415ef2a19d1703e35476403671f5801ce8665a8802511cec89e44a8868e144cee19986c2881f52ca6965
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/vpiotr/decimal_for_cpp/blob/master/doc/license.txt"
    FILENAME "License.txt"
    SHA512 8edf6bb6929008e69f4e17727ded4964f6e036ef66c2909c7070b75b14791023a9c7303ac6e61c0cc746649175ff96c0477aa7593c66b64a5f999f37a1cf7a58
)


file(COPY ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include ) 
file(COPY ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp )
file(RENAME ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/copyright) 

