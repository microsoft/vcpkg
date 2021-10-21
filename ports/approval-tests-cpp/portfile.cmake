vcpkg_download_distfile(single_header
    URLS https://github.com/approvals/ApprovalTests.cpp/releases/download/v.10.12.0/ApprovalTests.v.10.12.0.hpp
    FILENAME ApprovalTests.v.10.12.0.hpp
    SHA512 a6a5030cc4f438f218bb55c25124ed3df749d36a0f032ff21b3a68ee4334eb4562944a0f5f73d0c253d674517f8a819349371e248eca271ce5577236f1598b8c
)

vcpkg_download_distfile(license_file
    URLS https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.10.12.0/LICENSE
    FILENAME ApprovalTestsLicense.v.10.12.0
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
file(INSTALL "${license_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
