include(vcpkg_common_functions)

set(CATCH_VERSION v2.1.2)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/catchorg/Catch2/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catchorg-catch2-${CATCH_VERSION}.hpp"
    SHA512 4d6b26aff890fd543c05a780f777df6a3ac609d67d7bc6888377c7e18b7d8d371f12725a5ff03ce5c3fac05730e8b7116164c7173a04eb56ca38c2f3e3cbb9a6
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/catchorg/Catch2/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catchorg-catch2-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch2 RENAME copyright)
