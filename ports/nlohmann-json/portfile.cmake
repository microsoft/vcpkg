include(vcpkg_common_functions)

set(SOURCE_VERSION 3.1.2)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/json.hpp"
    FILENAME "nlohmann-json-${SOURCE_VERSION}.hpp"
    SHA512 05df0ad3338f0bca885c0aa9da523922b99016986a9b01426b13888c0febd83bf1f6f063886f6c75f8a656ef79abac6292fe442dc05b1897d546ba5b70be48a5
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/LICENSE.MIT"
    FILENAME "nlohmann-json-LICENSE-${SOURCE_VERSION}.txt"
    SHA512 0fdb404547467f4523579acde53066badf458504d33edbb6e39df0ae145ed27d48a720189a60c225c0aab05f2aa4ce4050dcb241b56dc693f7ee9f54c8728a75
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include/nlohmann RENAME json.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)
