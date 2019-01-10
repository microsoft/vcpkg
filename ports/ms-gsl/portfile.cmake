#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 0f68d133fa6fd2973951b8aaab481e34bbfd2cf4
    SHA512 1aa8116a75dd6ffd3a879dcf52f804e1d67e03bac3788559441ddebe2db6fd43a362bfa5ddac36954848555ba1e7fccb2d26b6060a9e171a04497ea551402b42
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
