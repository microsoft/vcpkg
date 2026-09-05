vcpkg_download_distfile(single_header
    URLS "https://github.com/approvals/ApprovalTests.cpp/releases/download/v.${VERSION}/ApprovalTests.v.${VERSION}.hpp"
    FILENAME "ApprovalTests.v.${VERSION}.hpp"
    SHA512 06887b2a7d9c9a18b052065e5a43bb02aeadb31095f655bf65c17f39271c5ede881afa521597a42820fd30d2680cfc2f2f516a9d74880b2d15bedf259c3881b6
)

vcpkg_download_distfile(license_file
    URLS "https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.${VERSION}/LICENSE"
    FILENAME "ApprovalTestsLicense.v.${VERSION}"
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
vcpkg_install_copyright(FILE_LIST "${license_file}")
