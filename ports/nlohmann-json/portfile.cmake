include(vcpkg_common_functions)

set(SOURCE_VERSION 3.0.1)

vcpkg_download_distfile(HEADER
    URLS "https://github.com/nlohmann/json/releases/download/v${SOURCE_VERSION}/json.hpp"
    FILENAME "nlohmann-json-${SOURCE_VERSION}.hpp"
    SHA512 95c0f0ca2e0eddfa462e732055ac6ede208929120bbe5c5d6e1035a7263900590bfeaddcbc4e1043aaa9255906cb0f038af64abf9a8da9fc98a7dc61356e2fef
)

vcpkg_download_distfile(LICENSE
    URLS "https://github.com/nlohmann/json/raw/v${SOURCE_VERSION}/LICENSE.MIT"
    FILENAME "nlohmann-json-LICENSE-${SOURCE_VERSION}.txt"
    SHA512 629ac4ed0128af8750ddaefb86b01e52243457020b54e3c38a1a772dbbc1598442a45ab9a0537bd47e35eafa73df0a9d1f1ebe235f339dcd2df1083219ded2d1
)

file(INSTALL ${HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include/nlohmann RENAME json.hpp)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)