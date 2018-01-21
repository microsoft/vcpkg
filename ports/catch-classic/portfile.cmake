include(vcpkg_common_functions)

set(CATCH_VERSION v1.12.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/catchorg/Catch2/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catch-classic-${CATCH_VERSION}.hpp"
    SHA512 0334993982a4543a42b301b77622dbc7df9e9c53dfe4e49a7b32cafea59f999e057777e94e719ecc0aafebc02fa937243d7ea6301be086a2dbd9f52b0d61d807
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/catchorg/Catch2/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catch-classic-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch-classic RENAME copyright)
