include(vcpkg_common_functions)

set(CATCH_VERSION v1.10.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/philsquared/Catch/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catch-${CATCH_VERSION}.hpp"
    SHA512 275ab5b5d778cc8a91b5f3e8f241a37b680c81d1b8945ff64ad16a9708c98e6535b389746bf8cacbed07f874629f456b56bafbf1879c5a6f84fa87675c1361b6
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catch-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch RENAME copyright)
