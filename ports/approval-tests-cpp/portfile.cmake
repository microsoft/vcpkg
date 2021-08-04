vcpkg_download_distfile(single_header
    URLS https://github.com/approvals/ApprovalTests.cpp/releases/download/v.10.9.1/ApprovalTests.v.10.9.1.hpp
    FILENAME ApprovalTests.v.10.9.1.hpp
    SHA512 520901982b8d217ce18f8729ca13e3d4c52ac87aa6a2f40089a49e7b85a4c3910ae3ca3a9fff1520c516dc726fad2ce70f122b8f061e606459af4e57de5fa2d6
)

vcpkg_download_distfile(license_file
    URLS https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.10.9.1/LICENSE
    FILENAME ApprovalTestsLicense.v.10.9.1
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
file(INSTALL "${license_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
