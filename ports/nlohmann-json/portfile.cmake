include(vcpkg_common_functions)

set(SOURCE_VERSION 3.0.0)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/json.hpp"
    FILENAME "nlohmann-json-${SOURCE_VERSION}.hpp"
    SHA512 0983320160900e7dbb1241d10f5be6eb0c1be39f2af3f153f488533c381e909f4af0d60c25c6a2e4bb7b69ad1ff0033651c52fe36886f917324f355281e99c05
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/LICENSE.MIT"
    FILENAME "nlohmann-json-LICENSE-${SOURCE_VERSION}.txt"
    SHA512 629ac4ed0128af8750ddaefb86b01e52243457020b54e3c38a1a772dbbc1598442a45ab9a0537bd47e35eafa73df0a9d1f1ebe235f339dcd2df1083219ded2d1
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include/nlohmann RENAME json.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)