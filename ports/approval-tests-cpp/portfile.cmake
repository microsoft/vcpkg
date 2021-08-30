vcpkg_download_distfile(single_header
    URLS https://github.com/approvals/ApprovalTests.cpp/releases/download/v.10.10.0/ApprovalTests.v.10.10.0.hpp
    FILENAME ApprovalTests.v.10.10.0.hpp
    SHA512 909302175fcaa23aea9839a8276a1c20b654e8544600bfb05d6bb76bc6a635f51ef6efe437ac07e01391724b2dc0e31cbf16bcb688fbec1ef3e378b027a6eb64
)

vcpkg_download_distfile(license_file
    URLS https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.10.10.0/LICENSE
    FILENAME ApprovalTestsLicense.v.10.10.0
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
file(INSTALL "${license_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
