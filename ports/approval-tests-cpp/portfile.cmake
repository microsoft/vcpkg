vcpkg_download_distfile(single_header
    URLS https://github.com/approvals/ApprovalTests.cpp/releases/download/v.10.11.0/ApprovalTests.v.10.11.0.hpp
    FILENAME ApprovalTests.v.10.11.0.hpp
    SHA512 2b43792b28a1dd44d76584c4d3bb9cb99563f92fdeafefd747516a8cfe0baf118b27ad235e1b023b3f5f3a34ecf920c12ab8a6d337776efc036456f4277142ae
)

vcpkg_download_distfile(license_file
    URLS https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.10.11.0/LICENSE
    FILENAME ApprovalTestsLicense.v.10.11.0
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
file(INSTALL "${license_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
