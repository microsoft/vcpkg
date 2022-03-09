vcpkg_download_distfile(single_header
    URLS https://github.com/approvals/ApprovalTests.cpp/releases/download/v.10.12.2/ApprovalTests.v.10.12.2.hpp
    FILENAME ApprovalTests.v.10.12.2.hpp
    SHA512 ed59736f52afff246409dcf435ad12a8f15697ae80962c456ca877fbf8adcb99af1bb71424ebcb214df719506015aac27006c1cfec174700b1833db64efb3568
)

vcpkg_download_distfile(license_file
    URLS https://raw.githubusercontent.com/approvals/ApprovalTests.cpp/v.10.12.2/LICENSE
    FILENAME ApprovalTestsLicense.v.10.12.2
    SHA512 dc6b68d13b8cf959644b935f1192b02c71aa7a5cf653bd43b4480fa89eec8d4d3f16a2278ec8c3b40ab1fdb233b3173a78fd83590d6f739e0c9e8ff56c282557
)

file(INSTALL "${single_header}" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME ApprovalTests.hpp)
file(INSTALL "${license_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
