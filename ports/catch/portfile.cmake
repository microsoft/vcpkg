include(vcpkg_common_functions)

set(CATCH_VERSION v1.11.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/philsquared/Catch/releases/download/${CATCH_VERSION}/catch.hpp"
    FILENAME "catch-${CATCH_VERSION}.hpp"
    SHA512 8ce490cfa433ec1c6b6460d76e1d9a6502966ada96fec7290fe9827a965751f3d572e97b93bbbb5e2bc97ffcf70bb547a050405b80a1a816054bd6afd1208cbe
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/philsquared/Catch/${CATCH_VERSION}/LICENSE.txt"
    FILENAME "catch-LICENSE-${CATCH_VERSION}.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch RENAME copyright)
