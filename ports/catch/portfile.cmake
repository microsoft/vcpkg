include(vcpkg_common_functions)

set(CATCH_VERSION v2.0.1)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/catchorg/Catch2/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catch-${CATCH_VERSION}.hpp"
    SHA512 e5e58c3a190cb0e848e19e885037e88e1b864e017f42b1306569850436c1c691b65640759d467061486931e7465a2b906fdd9e5208911b660fd960bf718305b4
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/catchorg/Catch2/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catch-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch RENAME copyright)
