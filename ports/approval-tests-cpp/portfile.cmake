vcpkg_download_distfile(single_header
    URLS https://github.com/approvals/ApprovalTests.cpp/releases/download/v.10.12.1/ApprovalTests.v.10.12.1.hpp
    FILENAME ApprovalTests.v.10.12.1.hpp
    SHA512 80921b8334c4c48380306a285e4f18f55872bced7a5f7f4c1a9db9c4fbd1cebf7c0ed8cca28e80b3024e34e2b41799976b1d36ecbf8d40e2bcfe45efab20d138
)

vcpkg_download_distfile(license_file
    URLS https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.10.12.1/LICENSE
    FILENAME ApprovalTestsLicense.v.10.12.1
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
file(INSTALL "${license_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
