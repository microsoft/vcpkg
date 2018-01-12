include(vcpkg_common_functions)

set(CATCH_VERSION v2.1.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/catchorg/Catch2/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catch-${CATCH_VERSION}.hpp"
    SHA512 6c2b9d4337369362b9079ac4eb53481e2db2a235af6ed0fa9d178775336a5c2d6aba1f86967f53de736aa198ae9d1acadd15a8c3ae2348c7dec0450e6452c716
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/catchorg/Catch2/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catch-LICENSE-${CATCH_VERSION}.txt"
    SHA512 f1a8d21ccbb6436d289ecfae65b9019278e40552a2383aaf6c1dfed98affe6e7bbf364d67597a131642b62446a0c40495e66a7efca7e6dff72727c6fd3776407
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch RENAME copyright)
