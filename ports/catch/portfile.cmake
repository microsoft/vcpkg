include(vcpkg_common_functions)

set(CATCH_VERSION v2.0.1)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/philsquared/Catch/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catch-${CATCH_VERSION}.hpp"
    SHA512 421a913e9c1671ef32833ec82c1889de69f74b80241708702873e54d804b1f7a3814ff01a34b945242e92d8a63cd668b0eb7f335b7fed352ef94679ad5295c0e
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catch-LICENSE-${CATCH_VERSION}.txt"
    SHA512 f1a8d21ccbb6436d289ecfae65b9019278e40552a2383aaf6c1dfed98affe6e7bbf364d67597a131642b62446a0c40495e66a7efca7e6dff72727c6fd3776407
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch RENAME copyright)
