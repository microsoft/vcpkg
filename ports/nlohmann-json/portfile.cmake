include(vcpkg_common_functions)

set(SOURCE_VERSION 3.5.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/json.hpp"
    FILENAME "nlohmann-json-${SOURCE_VERSION}.hpp"
    SHA512 6e8df9c0a8b5e74cc03f1c7620820215d43b642e213d30481830e5608c8196455dab5a5b604758c25dc6f45bd394fc0be6c8f8712a6498e96b3fd2e7d388d3c0
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/LICENSE.MIT"
    FILENAME "nlohmann-json-LICENSE-${SOURCE_VERSION}.txt"
    SHA512 0fdb404547467f4523579acde53066badf458504d33edbb6e39df0ae145ed27d48a720189a60c225c0aab05f2aa4ce4050dcb241b56dc693f7ee9f54c8728a75
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include/nlohmann RENAME json.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)
