include(vcpkg_common_functions)

set(SOURCE_VERSION 3.3.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/json.hpp"
    FILENAME "nlohmann-json-${SOURCE_VERSION}.hpp"
    SHA512 c4e4bb84d1488f87a02c4e12409491225e345cc508e6dbbee1a3542fbd4953052c256d0fe78c4d3ce02d44c3a2155fe66f0c8a93a3851ddf94fec4f9f3fd6918
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/LICENSE.MIT"
    FILENAME "nlohmann-json-LICENSE-${SOURCE_VERSION}.txt"
    SHA512 0fdb404547467f4523579acde53066badf458504d33edbb6e39df0ae145ed27d48a720189a60c225c0aab05f2aa4ce4050dcb241b56dc693f7ee9f54c8728a75
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include/nlohmann RENAME json.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)
