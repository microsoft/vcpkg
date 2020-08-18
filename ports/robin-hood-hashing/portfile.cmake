# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/robin-hood-hashing
    REF 3.7.0
    SHA512 3dd7c7ace50bd16579ef9db8f9a89e1b2fd8406d7f3af6a4cedb674ea14303bd70332da403b87b2f0fb3c7f415dd93e9a7b330cb86ca2f58d5916ca42666a8e5
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/src/include/robin_hood.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)