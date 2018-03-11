include(vcpkg_common_functions)

set(CATCH_VERSION v2.2.1)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/catchorg/Catch2/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catchorg-catch2-${CATCH_VERSION}.hpp"
    SHA512 89f707e667fabf1cc2be43b2ccf046a59007c68b8e4b37dde6799a960e57a9cdd1542289b83631ee6e450e22bf46cba477308ec872c1d0261c3bd4c218ab76fc
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/catchorg/Catch2/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catchorg-catch2-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch2 RENAME copyright)
