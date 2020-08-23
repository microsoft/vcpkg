vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO apolukhin/magic_get
	REF abb467c0e22a83bf75a46a9e6610370fabfc39af #Branch develop, Commits on Sep 2, 2019
	SHA512 1feb5d105d13a20aec8ab2c748dbd79ecc5d2267c8c0ee7db93a3d0c6b7186ea0c475fdc14712e78502ea839788f6dfb0b359e3fedbec59d331dafe137326fa4
	HEAD_REF develop
)

vcpkg_download_distfile(OCV_DOWNLOAD
    URLS "https://www.boost.org/LICENSE_1_0.txt"
    FILENAME "boost_license_1_0.txt"
    SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)

file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Handle copyright
# On Homepage README.md, License Distributed under the Boost Software License, Version 1.0. https://www.boost.org/LICENSE_1_0.txt
file(INSTALL ${OCV_DOWNLOAD} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
