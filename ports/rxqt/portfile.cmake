#header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tetsurom/rxqt
    REF master
    SHA512 3f25570ab98c8d3959c35b0d99d5c35486339aa8cd752d8140bb064239265ecb8c5002e3a5e2b46324bb79b558cfe0f17e23a59ad51e6d3a0764acdce493b12c
    HEAD_REF master
)

file(INSTALL
	${SOURCE_PATH}/include
    DESTINATION ${CURRENT_PACKAGES_DIR}
)

file(INSTALL
	${SOURCE_PATH}/LICENSE
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxqt RENAME copyright)