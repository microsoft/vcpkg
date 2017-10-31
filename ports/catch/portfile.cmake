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
    SHA512 f1a8d21ccbb6436d289ecfae65b9019278e40552a2383aaf6c1dfed98affe6e7bbf364d67597a131642b62446a0c40495e66a7efca7e6dff72727c6fd3776407
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME catch.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/catch RENAME copyright)
